--Chronologist Siblings
--Keddy was here~
local function ID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cod=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cod
end
xpcall(function() require("expansions/script/c39507090") end,function() require("script/c39507090") end)

local id,cod=ID()
function cod.initial_effect(c)
	--Special Summon
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EVENT_ADJUST)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(cod.tcop)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CUSTOM+id)
	e1:SetCondition(function (e) return e:GetHandler():GetFlagEffect(id)==1 end)
	e1:SetTarget(cod.lktg)
	e1:SetOperation(cod.lkop)
	c:RegisterEffect(e1)
	--Deactivate
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39507090,10))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id+1)
	e2:SetTarget(cod.dtg)
	e2:SetOperation(cod.dop)
	c:RegisterEffect(e2)
	--D&A
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(39507090,11))
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetCountLimit(1,id+1)
	e3:SetTarget(cod.atg)
	e3:SetOperation(cod.aop)
	c:RegisterEffect(e3)
end

--Turn Check
cod.turn={1}

cod.plist={PHASE_DRAW,PHASE_STANDBY,PHASE_MAIN1,
PHASE_BATTLE_START,PHASE_BATTLE_STEP,PHASE_DAMAGE,
PHASE_DAMAGE_CAL,PHASE_BATTLE,PHASE_MAIN2,PHASE_END}

function cod.tcop(e,tp,eg,ep,ev,re,r,rp)
	local t=cod.turn
	local c=e:GetHandler()
	if Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS) then
		local _,eg=Duel.CheckEvent(EVENT_SPSUMMON_SUCCESS,true)
		if eg:GetFirst()==c then
			if Duel.GetTurnCount()~=table.unpack(t) then
				t[1]=Duel.GetTurnCount()
			end
			return
		elseif eg:IsExists(function (c,ec) return c==ec end,1,nil,c) then
			if Duel.GetTurnCount()~=table.unpack(t) then
				t[1]=Duel.GetTurnCount()
			end
			return
		else return false end
	end
	if Duel.CheckEvent(EVENT_FLIP_SUMMON_SUCCESS) then
		local _,eg=Duel.CheckEvent(EVENT_FLIP_SUMMON_SUCCESS,true)
		if eg:GetFirst()==c then
			if Duel.GetTurnCount()~=table.unpack(t) then
				t[1]=Duel.GetTurnCount()
			end
			return
		end
	end
	if Duel.GetTurnCount()~=table.unpack(t) then
		t[1]=Duel.GetTurnCount()
		if c:IsLocation(LOCATION_MZONE) then
			Duel.RaiseSingleEvent(c,EVENT_CUSTOM+id,e,0,0,0,0)
			local ph=Duel.GetCurrentPhase()
			local phase=cod.plist
			local phv=0
			for i=1,#phase do
				if ph==phase[i] then
					if phase[i+1]==nil then
						phv=phase[i-(i-1)]
					else
						phv=phase[i+1]
					end
				end
			end
			if phv==0 then return end
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			e1:SetProperty(EFFECT_FLAG_DELAY)
			e1:SetCode(EVENT_PHASE+phv)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCountLimit(1)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetCondition(function (e) return e:GetHandler():GetFlagEffect(id)==1 end)
			e1:SetTarget(cod.lktg)
			e1:SetOperation(cod.lkop)
			c:RegisterEffect(e1)
		end
	end
end

--Special Summon
function cod.filter(c)
	return c:IsSetCard(0x593) and c:IsType(TYPE_MONSTER) and c:GetCode()~=id
end
function cod.lktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,0)>0
			and Duel.IsExistingTarget(cod.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,cod.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
function cod.lkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
end

--Deactivate
function cod.dfilter(c)
	return c:IsType(TYPE_LINK) and c:GetLinkMarker()~=0
end
function cod.dtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and cod.dfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cod.dfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,cod.dfilter,tp,LOCATION_ONFIELD,0,1,2,nil)
end
function cod.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:GetCount()<=0 then return end
	local tc=g:GetFirst()
	while tc do
		if not tc:IsRelateToEffect(e) then return end
		local lk,ops=Card.LinkCheck(tc)
		Duel.HintSelection(Group.FromCards(tc))
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,8))
		local op=Duel.SelectOption(tp,table.unpack(ops))
		link=tc:GetLinkMarker()-lk[op]
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
		e1:SetValue(link)
		e1:SetReset(RESET_EVENT+0x01fe0000)
		tc:RegisterEffect(e1,true)
		Duel.RaiseEvent(tc,EVENT_CUSTOM+39507090+tc:GetCode(),e,0,tp,tp,link)
		tc=g:GetNext()
	end
end

--D&A
function cod.afilter1(c,tp)
	return c:GetLinkMarker()~=0 and c:IsType(TYPE_LINK)
		and Duel.IsExistingMatchingCard(cod.afilter2,tp,LOCATION_ONFIELD,0,1,c)
end
function cod.afilter2(c)
   return c:GetLinkMarker()~=0 and c:IsType(TYPE_LINK)
end
function cod.atg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and cod.afilter1(chkc,tp) end
	if chk==0 then return Duel.IsExistingTarget(cod.afilter1,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,12))
	local g1=Duel.SelectTarget(tp,cod.afilter1,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	e:SetLabelObject(g1:GetFirst())
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,13))
	local g2=Duel.SelectTarget(tp,cod.afilter2,tp,LOCATION_ONFIELD,0,1,1,g1:GetFirst())
end
function cod.aop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if g:GetCount()<=0 then return end
	local tc=e:GetLabelObject()
	local g1=g:GetFirst()
	if g1==tc then
		ac=g:GetNext()
	else ac=g:GetFirst() end
	if not tc:IsRelateToEffect(e) 
		or not g:IsExists(function(c,tc) return c==tc end,1,nil,tc) then return end
	local lk,ops=Card.LinkCheck(tc)
	--First Card
	Duel.HintSelection(Group.FromCards(tc))
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,8))
	local op=Duel.SelectOption(tp,table.unpack(ops))
	link=tc:GetLinkMarker()-lk[op]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
	e1:SetValue(link)
	e1:SetReset(RESET_EVENT+0x01fe0000)
	tc:RegisterEffect(e1,true)
	Duel.RaiseEvent(tc,EVENT_CUSTOM+39507090+tc:GetCode(),e,0,tp,tp,link)
	if g:GetCount()==0 then return end
	--Second Card
	if not ac:IsRelateToEffect(e) or ac==tc then return end
	lk,ops=Card.LinkCheck(ac,1)
	Duel.HintSelection(Group.FromCards(ac))
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(39507090,9))
	local op=Duel.SelectOption(tp,table.unpack(ops))
	link=ac:GetLinkMarker()+lk[op]
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_LINK_MARKER_KOISHI)
	e2:SetValue(link)
	e2:SetReset(RESET_EVENT+0x01fe0000)
	ac:RegisterEffect(e2,true)
	Duel.RaiseEvent(ac,EVENT_CUSTOM+39507091+ac:GetCode(),e,0,tp,tp,link)
end