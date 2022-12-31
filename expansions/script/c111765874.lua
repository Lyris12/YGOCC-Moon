--Shaman Variamori
function c111765874.initial_effect(c)
 --banishing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(111765874,0))
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(2,111765874)
	e1:SetCondition(c111765874.dkcon)
	e1:SetTarget(c111765874.dktg)
	e1:SetOperation(c111765874.dkop)
	c:RegisterEffect(e1)
--special summon--
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c111765874.spcon)
	e2:SetOperation(c111765874.spop)
	e2:SetValue(1)
	c:RegisterEffect(e2)
--search
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(111765874,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c111765874.condition)
	e3:SetTarget(c111765874.thtg)
	e3:SetOperation(c111765874.thop)
	c:RegisterEffect(e3)
end
--banishing
function c111765874.dkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function c111765874.dktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp-1,LOCATION_DECK)
end
function c111765874.dkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g1=Duel.GetDecktopGroup(1-tp,3)
	Duel.DisableShuffleCheck()
	Duel.Remove(g1,POS_FACEDOWN,REASON_EFFECT)
end
--special summon--
function c111765874.spfilter(c)
	return c:IsSetCard(0x736) and c:IsLevelBelow(4)
end
function c111765874.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-1
		and Duel.CheckReleaseGroup(c:GetControler(),c111765874.spfilter,1,nil)
end
function c111765874.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(c:GetControler(),c111765874.spfilter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
--search
function c111765874.thfilter(c)
	return c:IsSetCard(0x736) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand() and not c:IsCode(111765874)
end
function c111765874.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function c111765874.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c111765874.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c111765874.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c111765874.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end