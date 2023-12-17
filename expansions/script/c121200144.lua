--Winter Wall
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: Keddy, XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRelevantTimings()
	e1:SetTarget(s.a_tg)
	c:RegisterEffect(e1)
	--cannotatk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.b_tg)
	c:RegisterEffect(e2)
	--notribute
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UNRELEASABLE_SUM)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.b_tg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e4)
	--nopos
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(s.b_tg)
	c:RegisterEffect(e5)
	--send and destroy
	local e6=Effect.CreateEffect(c)
	e6:Desc(1)
	e6:SetCategory(CATEGORY_TODECK|CATEGORY_DESTROY)
	e6:SetType(EFFECT_TYPE_QUICK_O)
	e6:SetCode(EVENT_FREE_CHAIN)
	e6:SetRange(LOCATION_GRAVE)
	e6:SetRelevantTimings()
	e6:SetCost(aux.bfgcost)
	e6:SetTarget(s.c_tg)
	e6:SetOperation(s.c_op)
	c:RegisterEffect(e6)
end
function s.a_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	c:SetTurnCounter(0)
	--destroy
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_PHASE|PHASE_STANDBY)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.a_dcd)
	e1:SetOperation(s.a_dop)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,2)
	c:RegisterEffect(e1)
end
function s.a_dcd(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.a_dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
	if ct==2 then
		Duel.Destroy(c,REASON_RULE)
	end
end

function s.b_tg(e,c)
	return c:GetCounter(COUNTER_ICE)>0 and not c:IsSetCard(ARCHE_WINTER_SPIRIT)
end

function s.c_cs(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end

function s.c_filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(ARCHE_WINTER_SPIRIT) and c:IsAbleToDeck()
end
function s.c_tfilter(c)
	return c:GetCounter(COUNTER_ICE)==0
end
function s.c_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.c_tfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return Duel.IsExistingMatchingCard(s.c_filter,tp,LOCATION_GRAVE,0,2,nil) and #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,2,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.c_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,aux.Necro(s.c_filter),tp,LOCATION_GRAVE,0,2,2,nil)
	if g:GetCount()>0 then
		Duel.HintSelection(g)
		if Duel.ShuffleIntoDeck(g)>0 then
			local dg=Duel.GetMatchingGroup(s.c_tfilter,tp,0,LOCATION_MZONE,nil)
			if #dg>0 then
				Duel.Destroy(dg,REASON_EFFECT)
			end
		end
	end
end