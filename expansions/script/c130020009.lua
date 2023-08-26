--Bomber Goblin's Barracks

--Automate ID
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET|EFFECT_FLAG_DELAY)
	e2:HOPT()
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:Desc(2)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:HOPT()
	e3:SetRelevantTimings()
	e3:SetCost(s.cost)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
--UNNECESSARY(?)
-- function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- local a=false
	-- local res,teg,tep,tev,tre,tr,trp=Duel.CheckEvent(EVENT_DESTROY,true)
	-- if res then
		-- a=tre and teg:IsExists(s.cfilter,1,nil,tre:GetHandler()) and s.target(e,tp,eg,ep,ev,re,r,rp,0)
	-- end
	-- if chk==0 then
		-- if a then e:SetHintTiming(TIMING_DESTROY) else e:SetHintTiming(0) end
		-- return true
	-- end
	-- local b=s.cost(e,tp,eg,ep,ev,re,r,rp,0) and s.thtg(e,tp,eg,ep,ev,re,r,rp,0,chkc)
	-- local op=aux.Option(tp,id,0,true,a,b)
	-- if op==0 then
		-- e:SetCategory(0)
		-- e:SetProperty(0)
		-- e:SetOperation(nil)
	-- elseif op==1 then
		-- e:SetCategory(CATEGORY_DRAW)
		-- e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		-- s.target(e,tp,eg,ep,ev,re,r,rp,1)
		-- e:SetOperation(s.operation)
		-- Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	-- elseif op==2 then
		-- e:SetCategory(CATEGORY_TOHAND)
		-- e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		-- s.cost(e,tp,eg,ep,ev,re,r,rp,1) s.thtg(e,tp,eg,ep,ev,re,r,rp,1,chkc)
		-- e:SetOperation(s.thop)
	-- end
-- end

function s.cfilter(c,rc)
	return c:IsSetCard(ARCHE_GRENADE_TYPE) and c:IsReason(REASON_EFFECT) and c==rc
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	return eg:IsExists(s.cfilter,1,nil,re:GetHandler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end

function s.costfilter(c)
	return c:IsSetCard(ARCHE_GRENADE_TYPE) and c:IsAbleToRemoveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,2,2,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
