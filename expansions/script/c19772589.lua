--AoJ - Ebonica
--Script by XGlitchy30
function c19772589.initial_effect(c)
	--pendulum summon
	aux.EnablePendulumAttribute(c)
	--PENDULUM EFFECTS
	--stats
	local e1p=Effect.CreateEffect(c)
	e1p:SetType(EFFECT_TYPE_FIELD)
	e1p:SetCode(EFFECT_UPDATE_ATTACK)
	e1p:SetRange(LOCATION_PZONE)
	e1p:SetTargetRange(0,LOCATION_MZONE)
	e1p:SetCondition(c19772589.statcon)
	e1p:SetValue(-500)
	c:RegisterEffect(e1p)
	local e2p=e1p:Clone()
	e2p:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2p)
	--recover resource
	local e3p=Effect.CreateEffect(c)
	e3p:SetDescription(aux.Stringid(19772589,0))
	e3p:SetCategory(CATEGORY_TODECK)
	e3p:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3p:SetRange(LOCATION_PZONE)
	e3p:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3p:SetCode(EVENT_TO_GRAVE)
	e3p:SetCountLimit(1,19772589)
	e3p:SetCondition(c19772589.tdcon)
	e3p:SetTarget(c19772589.tdtg)
	e3p:SetOperation(c19772589.tdop)
	c:RegisterEffect(e3p)
	--MONSTER EFFECTS
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19772589,1))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,11772589)
	e1:SetTarget(c19772589.sctg)
	e1:SetOperation(c19772589.scop)
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
	e5:SetCondition(c19772589.rdcon)
	e5:SetOperation(c19772589.rdop)
	c:RegisterEffect(e5)
end
--filters
function c19772589.tdfilter(c,tp,e)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x197) and c:GetPreviousControler()==tp and c:IsPreviousPosition(POS_FACEUP)
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsCanBeEffectTarget(e) and c:IsAbleToDeck()
end
function c19772589.scfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x197) and c:IsAbleToHand()
end
--stats
function c19772589.statcon(e)
	local tp=Duel.GetTurnPlayer()
	return tp~=e:GetHandlerPlayer()
end
--recover resource
function c19772589.tdcon(e,tp,eg,ep,ev,re,r,rp)
	local ph=Duel.GetCurrentPhase()
	return eg:IsExists(c19772589.tdfilter,1,nil,tp,e) and bit.band(r,REASON_DESTROY)~=0
		and Duel.GetTurnPlayer()==1-tp and ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
function c19772589.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=eg:GetFirst()
	if eg:GetCount()>1 then
		local g=Group.CreateGroup()
		while tc do
			if chkc then return chkc==tc end
			if chk==0 then return tc:GetPreviousControler()==tp and tc:IsPreviousLocation(LOCATION_MZONE)
			and tc:IsLocation(LOCATION_GRAVE) and tc:IsCanBeEffectTarget(e) and tc:IsAbleToDeck() end
			--
			if tc:GetPreviousControler()==tp and tc:IsPreviousLocation(LOCATION_MZONE) and tc:IsLocation(LOCATION_GRAVE) and tc:IsCanBeEffectTarget(e) and tc:IsAbleToDeck() then
				g:AddCard(tc)
			end
			tc=eg:GetNext()
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local td=g:Select(tp,1,1,nil)
		Duel.SetTargetCard(td:GetFirst())
		Duel.SetOperationInfo(0,CATEGORY_TODECK,td:GetFirst(),1,0,0)
	else
		if chkc then return chkc==tc end
		if chk==0 then return tc:GetPreviousControler()==tp and tc:IsPreviousLocation(LOCATION_MZONE)
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsCanBeEffectTarget(e) and tc:IsAbleToDeck() end
		Duel.SetTargetCard(tc)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,tc,1,0,0)
	end
end
function c19772589.tdop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoDeck(tc,nil,0,REASON_EFFECT)
	end
end
--search
function c19772589.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c19772589.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c19772589.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c19772589.scfilter,tp,LOCATION_DECK,0,1,1,nil)
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
function c19772589.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return ep~=tp and c==Duel.GetAttacker() and Duel.GetAttackTarget()==nil
		and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function c19772589.rdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev/2)
end