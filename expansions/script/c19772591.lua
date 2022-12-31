--La Grande Maga degli AoJ, Demetria Maxima
--Script by XGlitchy30
function c19772591.initial_effect(c)
	c:EnableReviveLimit()
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--PENDULUM EFFECTS
	--scale
	local e1p=Effect.CreateEffect(c)
	e1p:SetType(EFFECT_TYPE_SINGLE)
	e1p:SetCode(EFFECT_CHANGE_LSCALE)
	e1p:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1p:SetRange(LOCATION_PZONE)
	e1p:SetCondition(c19772591.slcon)
	e1p:SetValue(5)
	c:RegisterEffect(e1p)
	local e2p=e1p:Clone()
	e2p:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e2p)
	--banish
	local e3p=Effect.CreateEffect(c)
	e3p:SetCategory(CATEGORY_REMOVE)
	e3p:SetType(EFFECT_TYPE_IGNITION)
	e3p:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3p:SetRange(LOCATION_PZONE)
	e3p:SetCountLimit(1,19772591)
	e3p:SetCost(c19772591.rmcost)
	e3p:SetTarget(c19772591.rmtg)
	e3p:SetOperation(c19772591.rmop)
	c:RegisterEffect(e3p)
	--MONSTER EFFECTS
	--spsummon from deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19772591,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c19772591.spcon)
	e1:SetTarget(c19772591.sptg)
	e1:SetOperation(c19772591.spop)
	c:RegisterEffect(e1)
	--cannot direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e2:SetCondition(c19772591.dircon)
	c:RegisterEffect(e2)
	--extra attack
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19772591,1))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCountLimit(1,19772511)
	e3:SetCondition(c19772591.atcon)
	e3:SetCost(c19772591.atcost)
	e3:SetOperation(c19772591.atop)
	c:RegisterEffect(e3)
	--spsummon
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(19772591,2))
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c19772591.spsumcon)
	e4:SetTarget(c19772591.spsumtg)
	e4:SetOperation(c19772591.spsumop)
	c:RegisterEffect(e4)
end
--filters
function c19772591.slfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
function c19772591.costfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsSetCard(0x197) and c:IsAbleToGraveAsCost()
end
function c19772591.rmfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFacedown()
end
function c19772591.spfilter(c,e,tp)
	return c:IsSetCard(0x197) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c19772591.dirfilter(c)
	return c:IsSetCard(0x197) and c:GetLevel()==4
end
function c19772591.cffilter(c)
	return c:IsSetCard(0x197) and c:IsType(TYPE_SPELL) and not c:IsPublic()
end
--scale
function c19772591.slcon(e)
	return Duel.IsExistingMatchingCard(c19772591.slfilter,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler())
end
--banish
function c19772591.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19772591.costfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c19772591.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>1 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function c19772591.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c19772591.rmfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19772591.rmfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,c19772591.rmfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	if e:IsHasType(EFFECT_TYPE_IGNITION) then
		Duel.SetChainLimit(c19772591.limit(g:GetFirst()))
	end
end
function c19772591.limit(c)
	return	function (e,lp,tp)
				return e:GetHandler()~=c
			end
end
function c19772591.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
--spsummon from deck
function c19772591.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL)
end
function c19772591.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19772591.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c19772591.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c19772591.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
--cannot direct attack
function c19772591.dircon(e)
	return not Duel.IsExistingMatchingCard(c19772591.dirfilter,e:GetHandlerPlayer(),LOCATION_GRAVE,0,3,nil)
end
--extra attack
function c19772591.atcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetAttacker()==e:GetHandler() and aux.bdcon(e,tp,eg,ep,ev,re,r,rp)
		and e:GetHandler():IsChainAttackable(0)
end
function c19772591.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(c19772591.cffilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then 
		return dg:GetClassCount(Card.GetCode)>=3
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=dg:Select(tp,1,1,nil)
	dg:Remove(Card.IsCode,nil,g1:GetFirst():GetCode())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g2=dg:Select(tp,1,1,nil)
	dg:Remove(Card.IsCode,nil,g2:GetFirst():GetCode())
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g3=dg:Select(tp,1,1,nil)
	g1:Merge(g2)
	g1:Merge(g3)
	Duel.ConfirmCards(1-tp,g1)
	Duel.ShuffleHand(tp)
end
function c19772591.atop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChainAttack()
end
--spsummon
function c19772591.spsumcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
end
function c19772591.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c19772591.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c19772591.spsumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c19772591.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end