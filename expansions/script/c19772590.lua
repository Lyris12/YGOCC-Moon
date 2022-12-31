--AoJ - Ivorica
--Script by XGlitchy30
function c19772590.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--PENDULUM EFFECTS
	--stats
	local e1p=Effect.CreateEffect(c)
	e1p:SetType(EFFECT_TYPE_FIELD)
	e1p:SetCode(EFFECT_UPDATE_ATTACK)
	e1p:SetRange(LOCATION_PZONE)
	e1p:SetTargetRange(LOCATION_MZONE,0)
	e1p:SetCondition(c19772590.statcon)
	e1p:SetTarget(c19772590.stattg)
	e1p:SetValue(500)
	c:RegisterEffect(e1p)
	local e2p=e1p:Clone()
	e2p:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2p)
	--recover resource
	local e3p=Effect.CreateEffect(c)
	e3p:SetDescription(aux.Stringid(19772590,0))
	e3p:SetType(EFFECT_TYPE_QUICK_O)
	e3p:SetRange(LOCATION_PZONE)
	e3p:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL+EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3p:SetCode(EVENT_CHAINING)
	e3p:SetCountLimit(1,19772590)
	e3p:SetCondition(c19772590.setcon)
	e3p:SetCost(c19772590.setcost)
	e3p:SetTarget(c19772590.settg)
	e3p:SetOperation(c19772590.setop)
	c:RegisterEffect(e3p)
	--MONSTER EFFECTS
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19772590,1))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,11772590)
	e1:SetTarget(c19772590.sctg)
	e1:SetOperation(c19772590.scop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--defense attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--direct attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e4)
	--damage reduce
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e5:SetCondition(c19772590.rdcon)
	e5:SetOperation(c19772590.rdop)
	c:RegisterEffect(e5)
end
--filters
function c19772590.cfilter(c)
	return c:IsSetCard(0x197) and c:IsType(TYPE_SPELL) and c:IsAbleToGraveAsCost()
end
function c19772590.setfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
function c19772590.scfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x197) and c:IsAbleToHand()
end
--stats
function c19772590.statcon(e)
	local tp=Duel.GetTurnPlayer()
	return tp==e:GetHandlerPlayer()
end
function c19772590.stattg(e,c)
	return c:IsSetCard(0x197)
end
--recover resource
function c19772590.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
function c19772590.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19772590.cfilter,tp,LOCATION_DECK,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,c19772590.cfilter,tp,LOCATION_DECK,0,2,2,nil)
	if g:GetCount()>1 then
		Duel.SendtoGrave(g,REASON_COST)
	end
end
function c19772590.settg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c19772590.setfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(c19772590.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectTarget(tp,c19772590.setfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
function c19772590.setop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsSSetable() then
		Duel.SSet(tp,tc)
		Duel.ConfirmCards(1-tp,tc)
	end
end
--search
function c19772590.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19772590.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c19772590.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19772590.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToEffect(e) and c:IsCanChangePosition() then
			Duel.BreakEffect()
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end
--damage reduce
function c19772590.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c==Duel.GetAttacker() and Duel.GetAttackTarget()==nil
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function c19772590.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev/2)
end