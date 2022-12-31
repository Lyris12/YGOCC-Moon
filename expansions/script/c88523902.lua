--Kitseki Dragonis
--Script by XGlitchy30
function c88523902.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,88523902)
	e1:SetCondition(c88523902.spcon1)
	e1:SetTarget(c88523902.sptg)
	e1:SetOperation(c88523902.spop)
	c:RegisterEffect(e1)
	local e1x=Effect.CreateEffect(c)
	e1x:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1x:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1x:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e1x:SetCode(EVENT_TO_GRAVE)
	e1x:SetCountLimit(1,88523902)
	e1x:SetCondition(c88523902.spcon2)
	e1x:SetTarget(c88523902.sptg)
	e1x:SetOperation(c88523902.spop)
	c:RegisterEffect(e1x)
	--deck destruction
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(88523902,0))
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,81523902)
	e2:SetTarget(c88523902.ddtg)
	e2:SetOperation(c88523902.ddop)
	c:RegisterEffect(e2)
end
--filters
function c88523902.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x215a)
end
--special summon
function c88523902.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and re:GetHandler():IsSetCard(0x215a)
		and e:GetHandler():GetPreviousLocation()==LOCATION_DECK and e:GetHandler():GetPreviousControler()==tp
end
function c88523902.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT) and re:GetHandler():IsSetCard(0x215a) and e:GetHandler():GetPreviousControler()==tp
end
function c88523902.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c88523902.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
--deck destruction
function c88523902.ddtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(c88523902.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(1-tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
function c88523902.ddop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(c88523902.filter,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	end
end