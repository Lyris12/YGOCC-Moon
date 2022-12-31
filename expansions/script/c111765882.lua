--Failed Variamori
function c111765882.initial_effect(c)
	--banishing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(111765882,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c111765882.dkcon)
	e1:SetTarget(c111765882.dktg)
	e1:SetOperation(c111765882.dkop)
	e1:SetCountLimit(2,111765882)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,111765982+EFFECT_COUNT_CODE_OATH)
	e2:SetCondition(c111765882.spcon)
	c:RegisterEffect(e2)
end
--banishing
function c111765882.dkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c111765882.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp-1,LOCATION_DECK)
end
function c111765882.dkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetDecktopGroup(1-tp,2)
	Duel.DisableShuffleCheck()
	Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
end
--special summon
function c111765882.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x1736)
end
function c111765882.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c111765882.filter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end