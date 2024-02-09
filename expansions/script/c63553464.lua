--Inferioringranaggio - BLaDe
--Script by XGlitchy30
function c63553464.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	c:EnableCounterPermit(0x1554)
	--TRAP EFFECT
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63553464,1))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCondition(aux.PandActCheck)
	e2:SetCost(c63553464.tpcost)
	e2:SetTarget(c63553464.tptarget)
	e2:SetOperation(c63553464.operation)
	c:RegisterEffect(e2)
	aux.EnablePandemoniumAttribute(c,e2)
	--MONSTER EFFECTS
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetRange(LOCATION_HAND)
	e3:SetCountLimit(1,63553464)
	e3:SetCondition(c63553464.con)
	e3:SetTarget(c63553464.tg)
	e3:SetOperation(c63553464.op)
	c:RegisterEffect(e3)
	--pierce
	local prc=Effect.CreateEffect(c)
	prc:SetType(EFFECT_TYPE_SINGLE)
	prc:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(prc)
	--place counter
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c63553464.ctrcon)
	e4:SetOperation(c63553464.ctrop)
	c:RegisterEffect(e4)
	--search
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetTarget(c63553464.sctg)
	e5:SetOperation(c63553464.scop)
	c:RegisterEffect(e5)
	--Duel.AddCustomActivityCounter(63553464,ACTIVITY_SPSUMMON,c63553464.counterfilter)
end
--custom parameters
-- c63553464.pendulum_level=0   
-- c63553464.pcheck=true   --if "true" the monster will be treated as a Pandemonium card
-- c63553464.pscale1=4   --Left Pandemonium Scale
-- c63553464.pscale2=9   --Right Pandemonium Scale
--filters
function c63553464.tpcostfilter(c)
	return c:GetCounter(0x1554)>0
end
function c63553464.posfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
function c63553464.scfilter(c)
	return c:IsSetCard(0x4554) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
function c63553464.scfilter2(c)
	return c:IsSetCard(0x4554) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-----
function c63553464.p_act_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return true end
	if c63553464.tpcost(e,tp,eg,ep,ev,re,r,rp,0)
		and e:GetHandler():GetFlagEffect(63553464)<=0
		and Duel.IsExistingMatchingCard(c63553464.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		and Duel.SelectYesNo(tp,94) then
		c63553464.tpcost(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetCategory(CATEGORY_POSITION)
		c:RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,65)
	else
		e:SetCategory(0)
	end
end
function c63553464.tpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroup(tp,c63553464.tpcostfilter,1,nil) end
	local cg=Duel.SelectReleaseGroup(tp,c63553464.tpcostfilter,1,1,nil)
	e:SetLabel(cg:GetFirst():GetCounter(0x1554))
	Duel.Release(cg,REASON_COST)
end
function c63553464.tptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local ft=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local sum=e:GetLabel()
	if sum>ft then
		sum=ft
	end
	if chk==0 then return e:GetHandler():GetFlagEffect(63553464)<=0 and Duel.IsExistingMatchingCard(c63553464.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,LOCATION_MZONE)
end
function c63553464.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(63553464)>0 then return end
	e:GetHandler():RegisterFlagEffect(63553464,RESET_PHASE+PHASE_END,0,1)
	local ft=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	local sum=e:GetLabel()
	if sum<=0 then return end
	if sum>ft then
		sum=ft
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c63553464.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,sum,nil)
	if g:GetCount()>0 then
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
--set on field (effect)
function c63553464.cfilter(c,tp)
	return c:IsRace(RACE_MACHINE) and c:GetPreviousControler()==tp
end
function c63553464.con(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c63553464.cfilter,1,nil,tp)
end
function c63553464.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandSSetCon(e:GetHandler(),nil,LOCATION_HAND)(nil,e,tp,eg,ep,ev,re,r,rp) end
end
function c63553464.op(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if tc:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 and aux.PandSSetCon(e:GetHandler(),nil,LOCATION_HAND)(nil,e,tp,eg,ep,ev,re,r,rp) then
		aux.PandSSet(tc,REASON_EFFECT,TYPE_EFFECT)(e,tp,eg,ep,ev,re,r,rp)
		Duel.ConfirmCards(1-tp,tc)
	end
end
--place counter
function c63553464.ctrcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	return rc==e:GetHandler()
end
function c63553464.ctrop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c63553464.scfilter2,tp,LOCATION_DECK,0,1,nil) then return end
	e:GetHandler():AddCounter(0x1554,1)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c63553464.scfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--search
function c63553464.sctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c63553464.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c63553464.scop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c63553464.scfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end