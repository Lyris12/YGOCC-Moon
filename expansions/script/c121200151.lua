--Winter Spirit Death
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--counter
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetCondition(s.regcon)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetLabel(0)
	e1:SetLabelObject(e0)
	e1:SetCondition(s.a_cd)
	e1:SetOperation(s.a_op)
	c:RegisterEffect(e1)
	--ATK/DEF
	aux.AddWinterSpiritBattleEffect(c)
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local ct=eg:GetFirst():GetCounter(COUNTER_ICE)
	e:SetLabel(ct)
end

function s.a_cd(e,tp,eg,ep,ev,re,r,rp)
	return #eg==1 and e:GetLabelObject():GetLabel()>0
end
function s.a_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.Group(Card.IsFaceup,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	local ct0=e:GetLabelObject():GetLabel()
	if #g==0 or ct0<=0 then return end
	Duel.DistributeCounters(tp,COUNTER_ICE,ct0,g,id)
end