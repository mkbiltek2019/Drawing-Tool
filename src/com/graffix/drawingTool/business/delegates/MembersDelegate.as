package com.graffix.drawingTool.business.delegates
{
	import com.graffix.drawingTool.business.services.NetConnectionServices;
	import com.graffix.drawingTool.vo.MembersList;
	
	import flash.net.NetConnection;
	import flash.net.SharedObject;
	
	import mx.collections.ArrayCollection;

	public class MembersDelegate
	{
		public function MembersDelegate()
		{
			
		}
		
		public function getMembersList():MembersList
		{
			var list:MembersList = new MembersList();
			var membersSO:SharedObject = NetConnectionServices.instance.getMembersSO();
			for(var i:String in membersSO.data)
			{
				list.addItem(membersSO.data[i]);
			}
			return list; 
		}
		
		public function connect(prefix:String):void
		{
			var membersSO:SharedObject = NetConnectionServices.instance.getMembersSO(prefix);
			var nc:NetConnection = NetConnectionServices.instance.netConnection;
			nc.call(prefix+"connect", null);
		}
		
		public function setStatus(status:int, prefix:String):void
		{
			var nc:NetConnection = NetConnectionServices.instance.netConnection;
			nc.call(prefix+"setStatus", null, status);
		}
		
		public function setUsername(username:String, prefix:String):void
		{
			var nc:NetConnection = NetConnectionServices.instance.netConnection;
			nc.call(prefix+"changeName", null, username);
		}
	}
}