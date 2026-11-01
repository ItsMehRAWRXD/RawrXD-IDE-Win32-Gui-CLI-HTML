using System;
using System.IO;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;

class DumpRc {
  [DllImport("dbghelp.dll", SetLastError=true, CharSet=CharSet.Unicode)]
  static extern bool SymInitializeW(IntPtr hProcess, string UserSearchPath, bool fInvadeProcess);
  [DllImport("dbghelp.dll", SetLastError=true)] static extern bool SymCleanup(IntPtr hProcess);
  [DllImport("dbghelp.dll", SetLastError=true)] static extern uint SymSetOptions(uint SymOptions);
  [DllImport("dbghelp.dll", SetLastError=true, CharSet=CharSet.Unicode)]
  static extern ulong SymLoadModuleExW(IntPtr hProcess, IntPtr hFile, string ImageName, string ModuleName, ulong BaseOfDll, uint DllSize, IntPtr Data, uint Flags);
  [StructLayout(LayoutKind.Sequential, CharSet=CharSet.Ansi)]
  struct SYMBOL_INFO {
    public uint SizeOfStruct; public uint TypeIndex; ulong r0,r1;
    public uint Index, Size; public ulong ModBase, Flags, Value, Address;
    public uint Register, Scope, Tag, NameLen, MaxNameLen;
    [MarshalAs(UnmanagedType.ByValTStr, SizeConst=2048)] public string Name;
  }
  [DllImport("dbghelp.dll", SetLastError=true, CharSet=CharSet.Ansi)]
  static extern bool SymFromAddr(IntPtr hProcess, ulong Address, out ulong Displacement, ref SYMBOL_INFO Symbol);
  [StructLayout(LayoutKind.Sequential)]
  struct IMAGEHLP_LINE64P {
    public uint SizeOfStruct; public IntPtr Key; public uint LineNumber; public IntPtr FileName; public ulong Address;
  }
  [DllImport("dbghelp.dll", SetLastError=true)]
  static extern bool SymGetLineFromAddr64(IntPtr hProcess, ulong dwAddr, out uint pdwDisplacement, ref IMAGEHLP_LINE64P Line);

  static string SymName(IntPtr hp, ulong addr) {
    SYMBOL_INFO s = new SYMBOL_INFO();
    s.SizeOfStruct = 88; s.MaxNameLen = 2047;
    ulong disp;
    if (!SymFromAddr(hp, addr, out disp, ref s))
      return string.Format("??? err={0}", Marshal.GetLastWin32Error());
    IMAGEHLP_LINE64P line = new IMAGEHLP_LINE64P();
    line.SizeOfStruct = (uint)Marshal.SizeOf(typeof(IMAGEHLP_LINE64P));
    uint ld; string loc = "";
    if (SymGetLineFromAddr64(hp, addr, out ld, ref line) && line.FileName != IntPtr.Zero)
      loc = string.Format(" {0}:{1}", Marshal.PtrToStringAnsi(line.FileName), line.LineNumber);
    return string.Format("{0}+0x{1:X}{2}", s.Name, disp, loc);
  }

  static void Main(string[] args) {
    string dump = args[0], exe = args[1], search = args[2], outPath = args[3];
    var sb = new StringBuilder();
    ulong imgBase=0, imgSize=0, rip=0, rsp=0; uint tid=0, ctxRva=0; uint code=0; ulong p0=0;
    var stackRvas = new List<ulong>();
    using (var fs = new FileStream(dump, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
    using (var br = new BinaryReader(fs)) {
      br.ReadUInt32(); br.ReadUInt32();
      uint n=br.ReadUInt32(); uint dir=br.ReadUInt32();
      fs.Position=dir; uint exRva=0, modRva=0, memRva=0;
      for (uint i=0;i<n;i++){
        uint st=br.ReadUInt32(); br.ReadUInt32(); uint rva=br.ReadUInt32();
        if(st==6)exRva=rva; if(st==4)modRva=rva; if(st==9)memRva=rva;
      }
      fs.Position=modRva; br.ReadUInt32();
      imgBase=br.ReadUInt64(); imgSize=br.ReadUInt32();
      fs.Position=exRva; tid=br.ReadUInt32(); br.ReadUInt32();
      code=br.ReadUInt32(); br.ReadUInt32(); br.ReadUInt64(); ulong addr=br.ReadUInt64();
      uint np=br.ReadUInt32(); br.ReadUInt32(); p0=br.ReadUInt64();
      for(uint i=1;i<15;i++) br.ReadUInt64();
      br.ReadUInt32(); ctxRva=br.ReadUInt32();
      fs.Position=ctxRva; byte[] ctx=br.ReadBytes(1232);
      rsp=BitConverter.ToUInt64(ctx,0x98); rip=BitConverter.ToUInt64(ctx,0xF8);
      sb.AppendFormat("TID={0} CODE=0x{1:X8} P0=0x{2:X} RIP=0x{3:X} RIP_RVA=0x{4:X} RSP=0x{5:X} IMG=0x{6:X} SIZE=0x{7:X}\n",
        tid, code, p0, rip, rip-imgBase, rsp, imgBase, imgSize);
      fs.Position=memRva; ulong nr=br.ReadUInt64(); ulong baseRva=br.ReadUInt64();
      var ranges=new List<Tuple<ulong,ulong,ulong>>(); ulong fo=baseRva;
      for(ulong r=0;r<nr;r++){
        ulong s=br.ReadUInt64(); ulong z=br.ReadUInt64();
        ranges.Add(Tuple.Create(s,z,fo)); fo+=z;
      }
      Func<ulong,long?> toFile=(va)=>{
        foreach(var rg in ranges)
          if(va>=rg.Item1 && va<rg.Item1+rg.Item2)
            return (long)(rg.Item3+(va-rg.Item1));
        return null;
      };
      for(int i=0;i<256;i++){
        var f=toFile(rsp+(ulong)(i*8)); if(f==null) continue;
        fs.Position=f.Value; ulong v=br.ReadUInt64();
        if(v>=imgBase && v<imgBase+imgSize) stackRvas.Add(v-imgBase);
      }
    }
    IntPtr hp = new IntPtr(0x5150);
    SymSetOptions(0x10|0x4|0x1|0x40);
    if (!SymInitializeW(hp, search, false))
      sb.Append("SymInit fail "+Marshal.GetLastWin32Error()+"\n");
    ulong loaded = SymLoadModuleExW(hp, IntPtr.Zero, exe, null, imgBase, (uint)imgSize, IntPtr.Zero, 0);
    sb.AppendFormat("SymLoad=0x{0:X} err={1}\n", loaded, Marshal.GetLastWin32Error());
    ulong baseUse = loaded!=0 ? loaded : imgBase;
    sb.Append("FAULT: "+SymName(hp, rip)+"\n");
    var seen=new HashSet<ulong>();
    sb.Append("STACK_SYMS:\n");
    foreach(var rva in stackRvas){
      if(!seen.Add(rva)) continue;
      sb.AppendFormat("  RVA=0x{0:X} {1}\n", rva, SymName(hp, baseUse+rva));
    }
    foreach(var nameRva in new ulong[]{
      0x1F77359UL,0x4D0BE4UL,0x1F67CBEUL,0x1F316C0UL,0x1F30139UL,0x1F2EC72UL,0x1F6844FUL,0x13FB80CCUL
    }){
      sb.AppendFormat("DIRECT RVA=0x{0:X} {1}\n", nameRva, SymName(hp, baseUse+nameRva));
    }
    SymCleanup(hp);
    File.WriteAllText(outPath, sb.ToString());
    Console.WriteLine(sb.ToString());
  }
}
