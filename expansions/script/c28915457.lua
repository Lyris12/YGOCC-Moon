--Phantomb Raider, (Recovery)
local ref,id=GetID()
function ref.initial_effect(c)
	--ritual level
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_RITUAL_LEVEL)
	e0:SetValue(ref.rlevel)
	c:RegisterEffect(e0)
	--Set
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(ref.maketg(LOCATION_DECK))
	e1:SetOperation(ref.makeop(LOCATION_DECK,false))
	c:RegisterEffect(e1)
	--Recover
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(0,id))
	e2:SetRange(LOCATION_GRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(ref.maketg(LOCATION_GRAVE+LOCATION_EXTRA))
	e2:SetOperation(ref.makeop(LOCATION_GRAVE+LOCATION_EXTRA,true))
	c:RegisterEffect(e2)
end

--Ritual Level
function ref.rlevel(e,c)
	if c:IsSetCard(0x732) then
		return 3*65536+7
	else return e:GetHandler():GetLevel() end
end

--Set
function ref.setfilter(c)
	return c:IsSetCard(0x732) and c:GetType()&TYPE_PANDEMONIUM==TYPE_PANDEMONIUM
end
function ref.maketg(loc)
	return function(e,tp,eg,ep,ev,re,r,rp,chk)
		if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
			and Duel.IsExistingMatchingCard(ref.setfilter,tp,loc,0,1,nil)
			and aux.PandSSetCon(ref.setfilter,nil,loc)(nil,e,tp,eg,ep,ev,re,r,rp)
		end
	end
end
function ref.makeop(loc,actturn)
	return function(e,tp,eg,ep,ev,re,r,rp)
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or not aux.PandSSetCon(ref.setfilter,nil,loc)(nil,e,tp,eg,ep,ev,re,r,rp) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
		local g=Duel.SelectMatchingCard(tp,aux.PandSSetFilter(ref.setfilter),tp,loc,0,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
		local tc=g:GetFirst()
		if tc then
			aux.PandSSet(tc,REASON_EFFECT,aux.GetOriginalPandemoniumType(tc))(e,tp,eg,ep,ev,re,r,rp)
			Duel.ConfirmCards(1-tp,tc)
			if actturn then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
				e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
