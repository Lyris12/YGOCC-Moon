--HOPTifier
--Scripted by: XGlitchy30
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
local id,cid=getID()
function cid.initial_effect(c)
	--Activate	
	local e0=Effect.CreateEffect(c)	
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(0x5f)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e0:SetOperation(cid.preset)
	c:RegisterEffect(e0)
end
available_dtypes={
[LOCATION_DECK]={TYPE_EXTRA,OPCODE_ISTYPE,OPCODE_NOT}
}

prelist = {14060003,14060004,14060006,14060010,14060011,14060012,14060013,14060014,14060019,14060020,210001103,210001104,210001109,249000268,249000270}

--Activate
function cid.preset(e,tp,eg,ep,ev,re,r,rp)
	Debug.Message('START')
	local c=e:GetHandler()
	local draw_check=false
	if c:IsLocation(LOCATION_HAND) and Duel.SendtoDeck(c,nil,2,REASON_RULE)>0 then
		draw_check=true
	end
	Duel.Exile(c,REASON_RULE)
	--decide if mandatory or optional
	local check1=Duel.GetFieldGroupCount(tp,LOCATION_DECK+LOCATION_HAND,0)
	if check1<40 then
		cond=true
	else
		cond=Duel.SelectYesNo(tp,aux.Stringid(id,1))
	end 
	---------------
	if cond then
		local prep={}
		local minm=1
		if check1<40 then
			Debug.Message("Your deck size is less than 40. Please add the minimum number of cards")
			minm=40-check1
		end
		for maxm=1,minm do
			table.insert(prep,maxm)
		end
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(99988870,14))
		local ac=Duel.AnnounceNumber(tp,table.unpack(prep))
		while ac>0 do
			local dtype=available_dtypes[1]
			local cd=0
			local ok=true
			while ok do
				if dtype then
					cd=Duel.AnnounceCardFilter(tp,table.unpack(dtype))
				else
					cd=Duel.AnnounceCard(tp)
				end
				local fix=Duel.GetMatchingGroupCount(cid.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,nil,cd)
				if fix<3 then ok=false else Debug.Message("You already have 3 copies of this card") end
			end
			local slots={}
			local fix=Duel.GetMatchingGroupCount(cid.cfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_EXTRA,0,nil,cd)
			--choose correct number
			if ac>2 then
				for i=1,math.min(3,3-fix) do
					table.insert(slots,i)
				end
			elseif ac>1 then
				for i=1,math.min(2,3-fix) do
					table.insert(slots,i)
				end
			elseif ac==1 then
				for i=1,math.min(1,3-fix) do
					table.insert(slots,i)
				end
			end
			-----------
			local ctcard=Duel.AnnounceNumber(tp,table.unpack(slots))
			if fix~=0 then Debug.Message("The player has now "..tostring(fix+ctcard).." copies of "..tostring(cd).." in their Deck") end
			for cardnum=1,ctcard do
				local card=Duel.CreateToken(tp,cd)
				Duel.SendtoDeck(card,nil,0,REASON_RULE)
				if ac>0 then
					ac=ac-1
				end
			end
		end
		Duel.ShuffleDeck(tp)
	end
	if draw_check then Duel.Draw(tp,1,REASON_RULE) end
	
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local ok=true
		local fg=Duel.GetMatchingGroup(aux.TRUE,tp,0xff,0,nil)
		fg:KeepAlive()
		while ok do
			if #fg>0 then
				local fd=fg:Select(tp,0,1,nil)
				if fd:GetFirst() then
					local exg=Duel.GetMatchingGroup(cid.cfilter,tp,0xff,0,nil,fd:GetFirst():GetOriginalCode())
					fg:Sub(exg)
					for fc in aux.Next(exg) do
						fc:RegisterFlagEffect(id,0,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
					end
				else
					ok=false
				end
			else
				ok=false
			end
		end
	end
	
	local pre=false
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		pre=true
	end
				
	
	local omni=Duel.GetMatchingGroup(cid.filter,tp,0xff,0,nil,pre)
	for tc in aux.Next(omni) do
		local egroup=global_card_effect_table[tc]
		if #egroup>0 then
			for i=1,#egroup do
				local ce=egroup[i]
				local _,ctmax,ctflag=ce:GetCountLimit()
				if ce:IsHasType(EFFECT_TYPE_ACTIVATE+EFFECT_TYPE_TRIGGER+EFFECT_TYPE_QUICK+EFFECT_TYPE_IGNITION) and ((not ctmax or ctmax==1) and (not ctflag or ctflag==0)) then
					ce:SetCountLimit(1,tc:GetCode()+i*100)
				end
			end
		end
		tc:RegisterFlagEffect(id,0,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE,1)
	end
	
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCode(EFFECT_BECOME_HOPT)
	e1:SetTargetRange(1,0)
	Duel.RegisterEffect(e1,tp)
	
	Duel.ShuffleDeck(tp)
end

function cid.filter(c,pre)
	if not pre then
		return c:GetFlagEffect(id)<=0
	else
		for i=1,#prelist do
			if c:GetOriginalCode()==prelist[i] then
				return true
			end
		end
		return false
	end
end
function cid.cfilter(c,code)
	return c:GetOriginalCode()==code
end