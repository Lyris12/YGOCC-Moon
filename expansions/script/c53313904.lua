--Mysterious Servant Dragon
function c53313904.initial_effect(c)
	--If you control a Level 7 or higher "Mysterious" monster, you can Special Summon this card (from your hand). (HOPT1)
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_SPSUMMON_PROC)
	e0:SetRange(LOCATION_HAND)
	e0:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e0:SetCountLimit(1,53313904)
	e0:SetCondition(function(e,c)
		if c==nil then return true end
		local tp=c:GetControler()
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c53313904.spfilter,tp,LOCATION_MZONE,0,1,nil)
	end)
	c:RegisterEffect(e0)
	--When this card is targeted for an attack: You can Special Summon 1 "Mysterious Dragon" from your hand or face-up from your Extra Deck. (HOPT2)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53313904,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCountLimit(1,53313906)
	e1:SetTarget(c53313904.natg)
	e1:SetOperation(c53313904.naop)
	c:RegisterEffect(e1)
	--If a "Mysterious" monster(s) you control would be destroyed by battle or card effect, you can banish this card from your GY instead. (HOPT3)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,53313908)
	e2:SetTarget(c53313904.reptg)
	e2:SetValue(c53313904.repval)
	e2:SetOperation(c53313904.repop)
	c:RegisterEffect(e2)
end
function c53313904.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsSetCard(0xcf6)
end
function c53313904.aspfilter(c,e,tp)
	return ((c:IsLocation(LOCATION_HAND) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
		or (c:IsFaceup() and Duel.GetLocationCount(tp,LOCATION_MZONE)>0))
		and c:IsCode(53313901) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c53313904.natg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c53313904.aspfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_HAND)
end
function c53313904.naop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c53313904.spfilter,tp,LOCATION_HAND+LOCATION_EXTRA,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c53313904.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xcf6) and c:IsLocation(LOCATION_MZONE)
		and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
function c53313904.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemove() and eg:IsExists(c53313904.repfilter,1,nil,tp) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function c53313904.repval(e,c)
	return c53313904.repfilter(c,e:GetHandlerPlayer())
end
function c53313904.repop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)
end
