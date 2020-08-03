--Alchemage Master Helio
local function getID()
	local str=string.match(debug.getinfo(2,'S')['source'],"c%d+%.lua")
	str=string.sub(str,1,string.len(str)-4)
	local cid=_G[str]
	local id=tonumber(string.sub(str,2))
	return id,cid
end
local id,cid=getID()
function cid.initial_effect(c)
	--link summon
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,cid.matfilter,2)
	--Cannot Target
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e2:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(cid.tgcon)
	e2:SetTarget(cid.imtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Cannot Attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(cid.tgcon)
	e3:SetValue(cid.imtg)
	c:RegisterEffect(e3)
	--ATK Boost
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(cid.ccost)
	e1:SetTarget(cid.target)
	e1:SetOperation(cid.activate)
	c:RegisterEffect(e1)
end
function cid.imtg(e,c)
	return not (c:IsCode(21770262) or c:IsCode(21770263) or c:IsCode(21770264))
end
--Filters
function cid.matfilter(c)
	return c:IsSetCard(0x8108) and c:IsType(TYPE_MONSTER)
end
function cid.filter(c)
	return c:IsCode(21770262) or c:IsCode(21770263) or c:IsCode(21770264)
end
--Cannot Target/Attack
function cid.tgcon(e,c)
	return Duel.IsExistingMatchingCard(cid.filter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil)
end
--ATK Boost
function cid.ccost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,0,0x81081,1,REASON_COST) end
	local ct={}
	local countmax=Duel.GetCounter(tp,1,0,0x81081)
	e:SetLabel(0)
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then 
		for i=countmax,1,-1 do
			if Duel.IsCanRemoveCounter(tp,1,0,0x81081,i,REASON_COST)  then
				table.insert(ct,i)
			end
		end
		if #ct==1 then 
			Duel.RemoveCounter(tp,1,0,0x81081,1,REASON_COST)
			e:SetLabel(1)
		else
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
			local ac=Duel.AnnounceNumber(tp,table.unpack(ct))
			Duel.RemoveCounter(tp,1,0,0x81081,ac,REASON_COST)
			e:SetLabel(ac)
		end
	end
end
function cid.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
function cid.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(500+e:GetLabel()*200)
		tc:RegisterEffect(e1)
	end
end
