using System; using System.IO; using System.Text; using System.Collections.Generic;
class DumpStack {
  static void Main(string[] a) {
    string dump=a[0], outp=a[1];
    var sb=new StringBuilder();
    using(var fs=new FileStream(dump,FileMode.Open,FileAccess.Read,FileShare.ReadWrite))
    using(var br=new BinaryReader(fs)) {
      br.ReadUInt32(); br.ReadUInt32();
      uint n=br.ReadUInt32(); uint dir=br.ReadUInt32();
      fs.Position=dir; uint exRva=0, modRva=0, memRva=0;
      for(uint i=0;i<n;i++){ uint st=br.ReadUInt32(); br.ReadUInt32(); uint rva=br.ReadUInt32(); if(st==6)exRva=rva; if(st==4)modRva=rva; if(st==9)memRva=rva; }
      fs.Position=modRva; br.ReadUInt32(); ulong imgBase=br.ReadUInt64(); uint imgSize=br.ReadUInt32();
      fs.Position=exRva; uint tid=br.ReadUInt32(); br.ReadUInt32();
      uint code=br.ReadUInt32(); br.ReadUInt32(); br.ReadUInt64(); ulong addr=br.ReadUInt64();
      uint np=br.ReadUInt32(); br.ReadUInt32(); ulong p0=br.ReadUInt64();
      for(uint i=1;i<15;i++) br.ReadUInt64();
      br.ReadUInt32(); uint ctxRva=br.ReadUInt32();
      fs.Position=ctxRva; byte[] ctx=br.ReadBytes(1232);
      ulong rsp=BitConverter.ToUInt64(ctx,0x98); ulong rip=BitConverter.ToUInt64(ctx,0xF8);
      sb.AppendFormat("TID={0} CODE=0x{1:X8} P0=0x{2:X} ADDR=0x{3:X} RIP=0x{4:X} RSP=0x{5:X} IMG=0x{6:X} SIZE=0x{7:X}\n",
        tid,code,p0,addr,rip,rsp,imgBase,imgSize);
      fs.Position=memRva; ulong nr=br.ReadUInt64(); ulong baseRva=br.ReadUInt64();
      var ranges=new List<Tuple<ulong,ulong,ulong>>(); ulong fo=baseRva;
      for(ulong r=0;r<nr;r++){ ulong s=br.ReadUInt64(); ulong z=br.ReadUInt64(); ranges.Add(Tuple.Create(s,z,fo)); fo+=z; }
      Func<ulong,long?> toFile=(va)=>{ foreach(var rg in ranges) if(va>=rg.Item1 && va<rg.Item1+rg.Item2) return (long)(rg.Item3+(va-rg.Item1)); return null; };
      sb.Append("STACK_EXE_RETS:\n");
      for(int i=0;i<512;i++){
        var f=toFile(rsp+(ulong)(i*8)); if(f==null) continue;
        fs.Position=f.Value; ulong v=br.ReadUInt64();
        if(v>=imgBase && v<imgBase+imgSize)
          sb.AppendFormat("  [{0}] *RSP+0x{1:X}=0x{2:X} RVA=0x{3:X}\n", i, i*8, v, v-imgBase);
      }
    }
    File.WriteAllText(outp, sb.ToString());
    Console.WriteLine(sb.ToString());
  }
}
