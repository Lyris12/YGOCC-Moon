--Rotten Variamori
function c111765873.initial_effect(c)
 --banishing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(111765873,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(2,111765873)
	e1:SetCondition(c111765873.dkcon)
	e1:SetTarget(c111765873.dktg)
	e1:SetOperation(c111765873.dkop)
	c:RegisterEffect(e1)
--set
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(111765873,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetTarget(c111765873.settg)
	e2:SetCountLimit(2,111765973)
	e2:SetOperation(c111765873.setop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	c:RegisterEffect(e3)
end
--banishing
function c111765873.dkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c111765873.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,2,tp-1,LOCATION_DECK)
end
function c111765873.dkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetDecktopGroup(1-tp,2)
	Duel.DisableShuffleCheck()
	Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
end
--set
function c111765873.setfilter(c)
	return c:IsSetCard(0x736) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
function c111765873.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c111765873.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
function c111765873.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,c111765873.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SSet(tp,g:GetFirst())
		g:GetFirst():RegisterFlagEffect(2547033,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.ConfirmCards(1-tp,g)
	end
end