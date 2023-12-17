--Winter Spirit Krampus
--  Idea: Alastar Rainford
--  Script: Shad3
--  Editor: Keddy, XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--Proc
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(s.a_cd)
	e1:SetOperation(s.a_op)
	c:RegisterEffect(e1)
	--add counter
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_COUNTER)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.b_tg)
	e2:SetOperation(s.b_op)
	c:RegisterEffect(e2)
	--ATK/DEF
	aux.AddWinterSpiritBattleEffect(c)
end
function s.a_cd(e,c)
	if c==nil then return true end
	local tc=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsCanRemoveCounter(tp,1,1,COUNTER_ICE,2,REASON_COST)
end
function s.a_op(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.RemoveCounter(tp,1,1,COUNTER_ICE,2,REASON_RULE)
end

function s.ctfilter(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_ICE,1)
end
function s.b_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,#g,COUNTER_ICE,1)
end
function s.b_op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.ctfilter,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_ICE,1)
	end
end