--Child of the Tortravellers
function c10110013.initial_effect(c)
   --link summon
   aux.AddLinkProcedure(c,c10110013.mfilter,1,1)
   c:EnableReviveLimit()
   --indestructable
   local e1=Effect.CreateEffect(c)
   e1:SetType(EFFECT_TYPE_FIELD)
   e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
   e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
   e1:SetRange(LOCATION_MZONE)
   e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
   e1:SetTarget(c10110013.indtg)
   e1:SetValue(1)
   c:RegisterEffect(e1) 
   --set
   local e2=Effect.CreateEffect(c)
   e2:SetDescription(aux.Stringid(10110013,0))
   e2:SetRange(LOCATION_MZONE)
   e2:SetType(EFFECT_TYPE_IGNITION)
   e2:SetCountLimit(1,10110013)
   e2:SetTarget(c10110013.settg)
   e2:SetOperation(c10110013.setop)
   c:RegisterEffect(e2)
end

function c10110013.mfilter(c)
	return c:IsRace(RACE_AQUA) and not c:IsCode(10110013)
end

function c10110013.indtg(e,c)
	return e:GetHandler():GetLinkedGroup():IsContains(c)
end

function c10110013.setfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x4a5) and c:GetLocation(LOCATION_GRAVE)
end

function c10110013.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(c10110013.setfilter,tp,LOCATION_GRAVE,0,1,nil,tp) 
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,c10110013.setfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,tp)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end

function c10110013.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SSet(tp,tc)
	end
end