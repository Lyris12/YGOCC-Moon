--Venom Blazing Viper
function c16000872.initial_effect(c)
		aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,3,c16000872.filter2,1)
	--to hand
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16000872,0))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c16000872.spcon)
	e1:SetCost(c16000872.cost)
	e1:SetOperation(c16000872.spop)
	c:RegisterEffect(e1)
	--immune
		  --disable
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD)
	e6:SetRange(LOCATION_MZONE)
	e6:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e6:SetCode(EFFECT_DISABLE)
	e6:SetTarget(c16000872.distg)
	c:RegisterEffect(e6)
end



function c16000872.filter2(c,ec,tp)
	return c:IsRace(RACE_REPTILE) or c:IsAttribute(ATTRIBUTE_FIRE)
end
function c16000872.cfilter(c,tp,rp)
	return  c:IsRace(RACE_REPTILE) 
		and c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT)
end
function c16000872.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16000872.cfilter,1,nil,tp,rp)
end

function c16000872.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	   if chk==0 then return e:GetHandler():IsCanRemoveEC(tp,1,REASON_COST) end
	e:GetHandler():RemoveEC(tp,1,REASON_COST)
end
function c16000872.spop(e,tp,eg,ep,ev,re,r,rp)
	 if not e:GetHandler():IsRelateToEffect(e) then return end
	local g=Group.CreateGroup()
	local tg=Duel.GetFieldGroup(tp,LOCATION_MZONE,LOCATION_MZONE)
	local tc=tg:GetFirst()
	while tc do
		if tc:IsCanAddCounter(0x1009,1) and not tc:IsSetCard(0x50) then
			tc:AddCounter(0x1009,1)
			if tc:IsDisabled() then
				g:AddCard(tc)
			end
		end
		tc=tg:GetNext()
	end
	if g:GetCount()>0 then
		Duel.RaiseEvent(g,EVENT_CUSTOM+54306223,e,0,0,0,0)
	end
end

function c16000872.distg(e,c)
	return c:GetCounter(0x1009)>0 
end