--Wind Shaking Bird
function c500310009.initial_effect(c)
	   aux.AddOrigEvoluteType(c)
	c:EnableReviveLimit()
  aux.AddEvoluteProc(c,nil,6,c500310009.filter1,2,2)
	--disable search
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_TO_HAND)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c500310009.con)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLocation,LOCATION_DECK))
	c:RegisterEffect(e1)
		local e2=e1:Clone()
  e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e2:SetValue(1)
	c:RegisterEffect(e2)
	 --destroy replace
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EFFECT_DESTROY_REPLACE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTarget(c500310009.reptg)
	e4:SetValue(c500310009.repval)
	c:RegisterEffect(e4)

	
end
function c500310009.filter1(c,ec,tp)
	return c:IsRace(RACE_THUNDER) or c:IsAttribute(ATTRIBUTE_WIND)
end

function c500310009.con(e,tp,eg,ep,ev,re,r,rp)
	return  e:GetHandler():GetEC()==6
end
function c500310009.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsAttribute(ATTRIBUTE_WIND) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
end
function c500310009.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=eg:FilterCount(c500310009.repfilter,nil,tp)
	local g=Duel.GetDecktopGroup(tp,ct)
	if chk==0 then return g:IsExists(Card.IsAbleToRemove,ct,nil) end
	if Duel.SelectEffectYesNo(tp,e:GetHandler(),96) then
		Duel.DisableShuffleCheck()
		Duel.Remove(g,POS_FACEDOWN,REASON_EFFECT)
		return true
	else return false end
end
function c500310009.repval(e,c)
	return c500310009.repfilter(c,e:GetHandlerPlayer())
end
