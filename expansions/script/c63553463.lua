--Inferioringranaggio - ReID
--Script by XGlitchy30
function c63553463.initial_effect(c)
	aux.AddOrigPandemoniumType(c)
	c:EnableCounterPermit(0x1554)
	--TRAP EFFECT
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63553463,1))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1)
	e2:SetCondition(aux.PandActCheck)
	e2:SetCost(c63553463.tpcost)
	e2:SetTarget(c63553463.tptarget)
	e2:SetOperation(c63553463.operation)
	c:RegisterEffect(e2)
	aux.EnablePandemoniumAttribute(c,e2)
	--MONSTER EFFECTS
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3x:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3x:SetCode(EVENT_LEAVE_FIELD)
	e3x:SetLabel(100)
	e3x:SetCondition(c63553463.lfcon)
	e3x:SetOperation(c63553463.lfop)
	c:RegisterEffect(e3x)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetLabel(0)
	e3:SetCondition(c63553463.lfcon)
	e3:SetOperation(c63553463.lfop2)
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
	e4:SetCondition(c63553463.ctrcon)
	e4:SetOperation(c63553463.ctrop)
	c:RegisterEffect(e4)
	--spsummon
	local e5=Effect.CreateEffect(c)
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetTarget(c63553463.spsumtg)
	e5:SetOperation(c63553463.spsumop)
	c:RegisterEffect(e5)
	--Duel.AddCustomActivityCounter(63553463,ACTIVITY_SPSUMMON,c63553463.counterfilter)
end
--custom parameters
-- c63553463.pendulum_level=0   
-- c63553463.pcheck=true   --if "true" the monster will be treated as a Pandemonium card
-- c63553463.pscale1=1   --Left Pandemonium Scale
-- c63553463.pscale2=5   --Right Pandemonium Scale
--filters
function c63553463.tpcostfilter(c)
	return c:GetCounter(0x1554)>0
end
function c63553463.scfilter(c)
	return c:IsSetCard(0x4554) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
function c63553463.scfilter2(c)
	return c:IsSetCard(0x4554) and c:IsAbleToHand()
end
function c63553463.tgfilter(c)
	return c:GetCode()~=635533462
end
function c63553463.spsumfilter(c,e,tp)
	return c:GetLevel()<=5 and c:IsSetCard(0x4554) and not c:IsCode(63553463) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-----
-- function c63553463.p_act_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- local c=e:GetHandler()
	-- if chk==0 then return true end
	-- if c63553463.tpcost(e,tp,eg,ep,ev,re,r,rp,0)
		-- and e:GetHandler():GetFlagEffect(63553463)<=0
		-- and Duel.IsExistingMatchingCard(c63553463.scfilter,tp,LOCATION_DECK,0,1,nil)
		-- and Duel.SelectYesNo(tp,94) then
		-- c63553463.tpcost(e,tp,eg,ep,ev,re,r,rp,1)
		-- e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- c:RegisterFlagEffect(0,RESET_CHAIN,EFFECT_FLAG_CLIENT_HINT,1,0,65)
	-- else
		-- e:SetCategory(0)
	-- end
-- end
function c63553463.tpcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(c63553463.tpcostfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,c63553463.tpcostfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
	if g then
		e:SetLabel(g:GetCounter(0x1554))
		Duel.Destroy(g,REASON_COST)
	end
end
function c63553463.tptarget(e,tp,eg,ep,ev,re,r,rp,chk)
	local sum=e:GetLabel()
	if sum>3 then
		sum=3
	end
	if chk==0 then return e:GetHandler():GetFlagEffect(63553463)<=0 and Duel.IsExistingMatchingCard(c63553463.scfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function c63553463.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(63553463)>0 then return end
	e:GetHandler():RegisterFlagEffect(63553463,RESET_PHASE+PHASE_END,0,1)
	local sum=e:GetLabel()
	if sum<=0 then return end
	if sum>3 then
		sum=3
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c63553463.scfilter,tp,LOCATION_DECK,0,1,sum,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--place counters
function c63553463.lfcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		local c=eg:GetFirst()
		return rp~=tp and c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and (c:GetCounter(0x4554)>=2 or c==e:GetHandler())
	elseif e:GetLabel()==100 then
		local c=e:GetHandler()
		return rp~=tp and c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
	end
end
function c63553463.lfop2(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingTarget(c63553463.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then return end
	local c=eg:GetFirst()
	if rp~=tp and c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT) and (c:GetCounter(0x4554)>=2 or c==e:GetHandler()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectTarget(tp,c63553463.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
		if g and g:IsRelateToEffect(e) then
			g:AddCounter(0x1554,2,true)
		end
	end
end
function c63553463.lfop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingTarget(c63553463.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then return end
	local c=e:GetHandler()
	if rp~=tp and c:IsType(TYPE_MONSTER) and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectTarget(tp,c63553463.tgfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil):GetFirst()
		if g and g:IsRelateToEffect(e) then
			g:AddCounter(0x1554,2,true)
		end
	end
end
--place counter
function c63553463.ctrcon(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp then return false end
	local rc=eg:GetFirst()
	return rc==e:GetHandler()
end
function c63553463.ctrop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsExistingMatchingCard(c63553463.scfilter2,tp,LOCATION_DECK,0,1,nil) then return end
	e:GetHandler():AddCounter(0x1554,1)
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,c63553463.scfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
--spsummon
function c63553463.spsumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c63553463.spsumfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c63553463.spsumop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g = Duel.SelectMatchingCard(tp,c63553463.spsumfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end