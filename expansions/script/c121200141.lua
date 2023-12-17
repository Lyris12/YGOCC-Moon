--Frozen Tundra
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e0=Effect.CreateEffect(c)
	e0:Desc(0)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--counter1
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_REMOVE_COUNTER+COUNTER_ICE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetOperation(s.a_op)
	c:RegisterEffect(e2)
	--counter2
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_LEAVE_FIELD_P)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetOperation(s.regop)
	c:RegisterEffect(e3)
	--place counters when leaving
	local e4=Effect.CreateEffect(c)
	e4:Desc(1)
	e4:SetCategory(CATEGORY_COUNTER)
	e4:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetTarget(s.cttg2)
	e4:SetOperation(s.ctop2)
	e4:SetLabelObject(e3)
	c:RegisterEffect(e4)
end
function s.a_op(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(COUNTER_ICE,1)
end


function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetHandler():GetCounter(COUNTER_ICE)
	e:SetLabel(ct)
end
function s.cttg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=e:GetLabelObject():GetLabel()
	Duel.SetTargetParam(ct)
	if ct>0 then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,COUNTER_ICE,ct)
	end
end
function s.ctop2(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct0=Duel.GetTargetParam()
	if #g==0 or ct0<=0 then return end
	Duel.DistributeCounters(tp,COUNTER_ICE,ct0,g,id)
end