--Winter Spirit Giant
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,2,s.a_fil,aux.Stringid(id,0))
	--Place counter
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(aux.DetachSelfCost())
	e1:SetTarget(s.b_tg)
	e1:SetOperation(s.b_op)
	c:RegisterEffect(e1)
	--ATK/DEF
	aux.AddWinterSpiritBattleEffect(c)
end
function s.a_fil(c)
	return c:IsFaceup() and c:IsSetCard(ARCHE_WINTER_SPIRIT) and c:IsXyzType(TYPE_XYZ) and not c:IsCode(id)
end

function s.filter(c)
	return c:IsFaceup() and c:IsCanAddCounter(COUNTER_ICE,1)
end
function s.b_tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.Group(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,#g,COUNTER_ICE,1)
end

function s.b_op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	for tc in aux.Next(g) do
		tc:AddCounter(COUNTER_ICE,1)
	end
end