--Winter Spirit Yuki-onna
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: Keddy, XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),3,2)
	--Atk UP!
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(s.a_val)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	--Place counter
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetCategory(CATEGORY_COUNTER)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCost(aux.DetachSelfCost())
	e3:SetTarget(s.b_tg)
	e3:SetOperation(s.b_op)
	c:RegisterEffect(e3)
	--ATK/DEF
	aux.AddWinterSpiritBattleEffect(c)
end
function s.a_val(e,c)
	return Duel.GetCounter(0,1,1,COUNTER_ICE)*200
end

function s.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_ICE,1)
end
function s.b_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,COUNTER_ICE,1)
end

function s.b_op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		g:GetFirst():AddCounter(COUNTER_ICE,1)
	end
end