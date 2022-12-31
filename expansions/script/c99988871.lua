--Speed Duel Mode
--Script by XGlitchy30
local cid,id=GetID()
function cid.initial_effect(c)
	--Activate	
	local e0=Effect.CreateEffect(c)	
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE)
	e0:SetCode(EVENT_PREDRAW)
	e0:SetRange(0x5f)
	e0:SetCountLimit(1,id+EFFECT_COUNT_CODE_DUEL)
	e0:SetCondition(cid.prevent_conflict)
	e0:SetOperation(cid.preset)
	c:RegisterEffect(e0)
end
cid.glitched_id = 1
available_dtypes={
[1]={TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK,OPCODE_ISTYPE,OPCODE_NOT};
[2]={0x2889,OPCODE_ISSETCARD,TYPE_PENDULUM,OPCODE_ISTYPE,OPCODE_AND};
}
--filters
function cid.glitched(c)
	local m=_G["c"..c:GetCode()]
	if not m then return false end
	local glitchid=m.glitched_id
	return glitchid and glitchid>0
end
function cid.confirmcard(c,card)
	return c==card
end
function cid.conflict(c,e)
	local loc=_G["c"..e:GetHandler():GetCode()]
	local m=_G["c"..c:GetCode()]
	if not m then return false end
	local localid=loc.glitched_id
	local glitchid=m.glitched_id
	return (glitchid and glitchid<localid) or (glitchid and c:IsControler(1-e:GetHandler():GetControler()) and glitchid<=localid)
end
function cid.conflict_info(c,e)
	local loc=_G["c"..e:GetHandler():GetCode()]
	local m=_G["c"..c:GetCode()]
	if not m then return false end
	local localid=loc.glitched_id
	local glitchid=m.glitched_id
	return glitchid and glitchid>=localid
end
--Activate
function cid.prevent_conflict(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(cid.conflict,tp,LOCATION_DECK+LOCATION_HAND,LOCATION_DECK+LOCATION_HAND,1,e:GetHandler(),e)
		and e:GetHandler():GetFlagEffect(99988870)<=0
end
function cid.preset(e,tp,eg,ep,ev,re,r,rp)
	local op=Duel.SelectOption(tp,aux.Stringid(id,5),aux.Stringid(id,6),aux.Stringid(id,7),aux.Stringid(id,8))
	--Duel Start handfix
	local drawcount1,drawcount2=0,0
	if op==0 then
		local startlimit,startlimit2=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0),Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)
		if startlimit>4 then
			for i=1,startlimit-4 do
				local rdm=Duel.GetFieldGroup(tp,LOCATION_HAND,0):GetFirst()
				Duel.SendtoDeck(rdm,nil,1,REASON_RULE)
			end
		end
		if startlimit2>4 then
			for i=1,startlimit2-4 do
				local rdm=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0):GetFirst()
				Duel.SendtoDeck(rdm,nil,1,REASON_RULE)
			end
		end
	end
	if Duel.IsExistingMatchingCard(cid.glitched,tp,LOCATION_HAND,LOCATION_HAND,1,nil) then
		local g=Duel.GetMatchingGroup(cid.glitched,tp,LOCATION_HAND+LOCATION_DECK,LOCATION_HAND+LOCATION_DECK,nil)
		local hand1=Duel.GetMatchingGroup(cid.glitched,tp,LOCATION_HAND,0,nil)
		local hand2=Duel.GetMatchingGroup(cid.glitched,tp,0,LOCATION_HAND,nil)
		drawcount1,drawcount2=hand1:GetCount(),hand2:GetCount()
		for i in aux.Next(g) do
			Duel.Remove(i,POS_FACEUP,REASON_RULE)
			if i:GetControler(tp) then
				Duel.SendtoDeck(i,nil,1,REASON_RULE)
			else
				Duel.SendtoDeck(i,nil,1,REASON_RULE)
			end
		end
	end
	---------------
	local excount1,excount2=0,0
	--remove other Glitched Cards
	if Duel.IsExistingMatchingCard(cid.conflict_info,tp,LOCATION_DECK,LOCATION_DECK,1,e:GetHandler(),e) then
		Debug.Message("Found multiple Glitched Cards in the decks with equal or lower ID than Speed Duel Mode")
		Debug.Message("All other Glitched Cards will be removed")
		local exclude=Duel.GetMatchingGroup(cid.conflict_info,tp,LOCATION_DECK,LOCATION_DECK,e:GetHandler(),e)
		for i in aux.Next(exclude) do
			local p=i:GetControler()
			Duel.Exile(i,REASON_RULE)
			if p==tp then
				excount1=excount1+1
			else
				excount2=excount2+1
			end
		end
	end
	--compensate for opponent	
	if not Duel.SelectYesNo(1-tp,aux.Stringid(id,2)) then
		Debug.Message("A player does not want to play with Speed Duel Mode")
		Debug.Message("The conditions for a Speed Duel have not been met")
		return
	end
	--Speed Duel Mode Activation
	local cp=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_DECK,e:GetHandler(),id)
	--fix for opponent's multiples
	if cp:GetCount()>0 then
		local remainder=cp:GetCount()
		Debug.Message("Found multiple copies of Speed Duel Mode in your opponent's Deck. Wait while we remove the unnecessary ones")
		for tm=1,remainder do
			local exc=cp:GetFirst()
			Duel.Exile(exc,REASON_RULE)
			excount2=excount2+1
		end
	end
	-----------
	Duel.Exile(e:GetHandler(),REASON_RULE)
	excount1=excount1+1
	--check valid deck size
	if op==0 then
		local checksz,checksz2=Duel.GetFieldGroupCount(tp,LOCATION_DECK+LOCATION_HAND,0),Duel.GetFieldGroupCount(1-tp,LOCATION_DECK+LOCATION_HAND,0)
		if checksz>30 or checksz2>30 then
			Debug.Message("Found a deck that contains more than 30 cards. The Duel will be stopped, please adjust your Deck in Deck Building")
			Duel.Win(tp,0x1)
		end
	end
	--add missing cards
	if excount1>0 then
		local minimum,maximum=20,30
		if op==1 then minimum,maximum=40,60 end
		local cond=false
		local check1=Duel.GetFieldGroupCount(tp,LOCATION_DECK+LOCATION_HAND,0)
		--decide if mandatory or optional
		if check1<minimum then
			cond=true
		elseif check1<maximum then
			if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				cond=true
			else
				cond=false
			end
		else
			cond=false
		end
		---------------
		if cond then
			local prep={}
			local slots
			local minm=1
			local fixcount=excount1
			if check1<minimum then
				Debug.Message("Your deck size is less than 20. Please add the minimum number of cards")
				minm=minimum-check1
			end
			if check1+fixcount>maximum then
				fixcount=maximum-check1
			end
			if fixcount>0 then
				for maxm=minm,fixcount do
					table.insert(prep,maxm)
				end
				Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
				local ac=Duel.AnnounceNumber(tp,table.unpack(prep))
				while ac>0 do
					local dtype=available_dtypes[1]
					local cd=0
					if dtype then
						cd=Duel.AnnounceCardFilter(tp,table.unpack(dtype))
					else
						cd=Duel.AnnounceCard(tp)
					end
					--choose correct number
					if ac>2 then
						slots = {1,2,3}
					elseif ac>1 then
						slots = {1,2}
					elseif ac==1 then
						slots = {1}
					end
					-----------
					local ctcard=Duel.AnnounceNumber(tp,table.unpack(slots))
					for cardnum=1,ctcard do
						local card=Duel.CreateToken(tp,cd)
						Duel.SendtoDeck(card,tp,0,REASON_RULE)
						if ac>0 then
							ac=ac-1
						end
					end
				end
			end
		end
	end
	if excount2>0 then
		local minimum,maximum=20,30
		if op==1 then minimum,maximum=40,60 end
		local cond=false
		local check1=Duel.GetFieldGroupCount(1-tp,LOCATION_DECK+LOCATION_HAND,0)
		--decide if mandatory or optional
		if check1<minimum then
			cond=true
		elseif check1<maximum then
			if Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				cond=true
			else
				cond=false
			end
		else
			cond=false
		end
		---------------
		if cond then
			local minm=1
			local fixcount=excount2
			local prep={}
			local slots
			if check1<minimum then
				Debug.Message("Your deck size is less than 20. Please add the minimum number of cards")
				minm=maximum-check1
			end
			if check1+fixcount>maximum then
				fixcount=maximum-check1
			end
			for maxm=minm,fixcount do
				table.insert(prep,maxm)
			end
			if fixcount>0 then
				Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,3))
				local ac=Duel.AnnounceNumber(1-tp,table.unpack(prep))
				while ac>0 do
					local dtype=available_dtypes[1]
					local cd=0
					if dtype then
						cd=Duel.AnnounceCardFilter(1-tp,table.unpack(dtype))
					else
						cd=Duel.AnnounceCard(1-tp)
					end
					--choose correct number
					if ac>2 then
						slots = {1,2,3}
					elseif ac>1 then
						slots = {1,2}
					elseif ac==1 then
						slots = {1}
					end
					-----------
					local ctcard=Duel.AnnounceNumber(1-tp,table.unpack(slots))
					for cardnum=1,ctcard do
						local card=Duel.CreateToken(1-tp,cd)
						Duel.SendtoDeck(card,nil,0,REASON_RULE)
						if ac>0 then
							ac=ac-1
						end
					end
				end
			end
		end
	end
	Duel.ShuffleDeck(tp)
	Duel.ShuffleDeck(1-tp)
	Duel.Draw(tp,drawcount1,REASON_RULE)
	Duel.Draw(1-tp,drawcount2,REASON_RULE)
	--adjust LPs
	if op~=1 and op~=3 then
		local lpval=4000
		if op==2 then
			local lp_list={}
			for ltemp=2000,16000,2000 do
				table.insert(lp_list,ltemp)
			end
			lpval=Duel.AnnounceNumber(tp,table.unpack(lp_list))
		end
		for lpp=0,1 do
			if Duel.GetLP(lpp)~=lpval then
				Duel.SetLP(lpp,lpval)
			end
		end
		--adjust extra deck
		local extrag=Group.CreateGroup()
		local extramax=5
		if op==2 then
			max_list={1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}
			extramax=Duel.AnnounceNumber(tp,table.unpack(max_list))
		end
		for extrap=0,1 do
			local extra=Duel.GetFieldGroup(extrap,LOCATION_EXTRA,0)
			if #extra>extramax then
				local extrile=extra:Select(extrap,#extra-extramax,#extra-extramax,nil)
				extrag:Merge(extrile)
			end
		end
		if #extrag>0 then
			Duel.Exile(extrag,REASON_RULE)
		end
		--modify field
		local pz1s,pz2s=0,4
		local pz1o,pz2o=0,4
		if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,1,nil,TYPE_PENDULUM) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			pz1s,pz2s=1,3
		end
		if Duel.IsExistingMatchingCard(Card.IsType,1-tp,LOCATION_DECK+LOCATION_EXTRA+LOCATION_HAND,0,1,nil,TYPE_PENDULUM) and Duel.SelectYesNo(1-tp,aux.Stringid(id,1)) then
			pz1o,pz2o=1,3
		end
		local df1=Effect.CreateEffect(e:GetHandler())
		df1:SetType(EFFECT_TYPE_FIELD)
		df1:SetCode(EFFECT_DISABLE_FIELD)
		df1:SetOperation(function (e,tp)
							return bit.lshift(0x1,0)
						end)
		Duel.RegisterEffect(df1,tp)
		local df2=df1:Clone()
		df2:SetOperation(function (e,tp)
							return bit.lshift(0x1,4)
						end)
		Duel.RegisterEffect(df2,tp)
		local df3=df1:Clone()
		Duel.RegisterEffect(df3,1-tp)
		local df4=df2:Clone()
		Duel.RegisterEffect(df4,1-tp)
		local df5=df1:Clone()
		df5:SetOperation(function (e,tp)
							return bit.lshift(0x100,pz1s)
						end)
		Duel.RegisterEffect(df5,tp)
		local df6=df1:Clone()
		df6:SetOperation(function (e,tp)
							return bit.lshift(0x100,pz2s)
						end)
		Duel.RegisterEffect(df6,tp)
		local df7=df5:Clone()
		df7:SetOperation(function (e,tp)
							return bit.lshift(0x100,pz1o)
						end)
		Duel.RegisterEffect(df7,1-tp)
		local df8=df6:Clone()
		df8:SetOperation(function (e,tp)
							return bit.lshift(0x100,pz2o)
						end)
		Duel.RegisterEffect(df8,1-tp)
		--skip phase
		local sk=Effect.CreateEffect(e:GetHandler())
		sk:SetType(EFFECT_TYPE_FIELD)
		sk:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		sk:SetTargetRange(1,1)
		sk:SetCode(EFFECT_SKIP_M2)
		Duel.RegisterEffect(sk,tp)
	end
	--enable skills
	if op==3 then
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
			for pp=0,1 do
				local dtype=available_dtypes[2]
				local cd=0
				cd=Duel.AnnounceCardFilter(pp,table.unpack(dtype))
				local card=Duel.CreateToken(pp,cd)
				Duel.Remove(card,POS_FACEUP,REASON_RULE)
				Duel.SendtoExtraP(card,pp,REASON_RULE)
				card:RegisterFlagEffect(id,RESET_EVENT+EVENT_CUSTOM+id,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
				--tag partner skill
				local cd2=0
				cd2=Duel.AnnounceCardFilter(pp,table.unpack(dtype))
				local card2=Duel.CreateToken(pp,cd2)
				local savecode=card2:GetCode()
				Duel.Exile(card2,REASON_RULE)
				local e0=Effect.CreateEffect(e:GetHandler())	
				e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e0:SetCode(EVENT_ADJUST)
				e0:SetLabel(savecode)
				e0:SetCondition(cid.tagskillcon)
				e0:SetOperation(cid.tagskill)
				Duel.RegisterEffect(e0,pp)
			end
		end
	else
		if Duel.SelectYesNo(tp,aux.Stringid(id,0)) and Duel.SelectYesNo(1-tp,aux.Stringid(id,0)) then
			for pp=0,1 do
				local dtype=available_dtypes[2]
				local cd=0
				cd=Duel.AnnounceCardFilter(pp,table.unpack(dtype))
				local card=Duel.CreateToken(pp,cd)
				Duel.Remove(card,POS_FACEUP,REASON_RULE)
				Duel.SendtoExtraP(card,pp,REASON_RULE)
				card:RegisterFlagEffect(id,RESET_EVENT+EVENT_CUSTOM+id,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
			end
		end
	end
end
--tag partner skill
function cid.tagskillcon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,0xff,0,1,nil,TYPE_SKILL)
end
function cid.tagskill(e,tp,eg,ep,ev,re,r,rp)
	local cd2=e:GetLabel()
	local card2=Duel.CreateToken(tp,cd2)
	Duel.Remove(card2,POS_FACEUP,REASON_RULE)
	Duel.SendtoExtraP(card2,tp,REASON_RULE)
	card2:RegisterFlagEffect(id,RESET_EVENT+EVENT_CUSTOM+id,EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE,1)
	e:Reset()
end