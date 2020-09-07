--Winged Variamori
function c111765870.initial_effect(c)
 --banishing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(111765870,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c111765870.dkcon)
	e1:SetTarget(c111765870.dktg)
	e1:SetOperation(c111765870.dkop)
	e1:SetCountLimit(2,111765870)
	c:RegisterEffect(e1)
--spsummon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(111765870,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetTarget(c111765870.tg)
	e2:SetOperation(c111765870.op)
	c:RegisterEffect(e2)
end
--banishing
function c111765870.dkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c111765870.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp-1,LOCATION_DECK)
end
function c111765870.dkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetDecktopGroup(1-tp,2)
	Duel.DisableShuffleCheck()
	Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
end
--spsummmon
function c111765870.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_HAND,0,1,e:GetHandler(),0x736)
		and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,false,false)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c111765870.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_HAND,0,nil,0x736)
	if g:GetCount()==0 then return end
	if g:GetCount()==1 then
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local sg=g:Select(tp,1,1,e:GetHandler())
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_DISCARD)
	end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,1,tp,tp,false,false,POS_FACEUP)
end