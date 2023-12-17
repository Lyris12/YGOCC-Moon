--Winter Spirit Nikoli
--Idea: Alastar Rainford
--Original Scripter: Shad3
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,ARCHE_WINTER_SPIRIT),s.a_fil2,true)
	aux.AddContactFusionProcedure(c,s.cfilter,LOCATION_MZONE,LOCATION_MZONE,Duel.SendtoGrave,REASON_COST)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(s.a_val)
	c:RegisterEffect(e1)
	--cannot be fusion material
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_UNCOPYABLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--Destroy
	local e4=Effect.CreateEffect(c)
	e4:Desc(0)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetRelevantTimings()
	e4:SetCost(s.b_cs)
	e4:SetTarget(s.b_tg)
	e4:SetOperation(s.b_op)
	c:RegisterEffect(e4)
	--ATK/DEF
	aux.AddWinterSpiritBattleEffect(c)
end
function s.a_fil2(c)
	return c:GetCounter(COUNTER_ICE)>=3
end
function s.cfilter(c,fc)
	return c:IsAbleToGraveAsCost() and (c:IsControler(fc:GetControler()) or c:IsFaceup())
end

function s.a_val(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end


function s.b_cs(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsCanRemoveCounter(tp,1,1,COUNTER_ICE,2,REASON_COST) end
	Duel.RemoveCounter(tp,1,1,COUNTER_ICE,2,REASON_COST)
end

function s.b_tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	Duel.SetCardOperationInfo(g,CATEGORY_DESTROY)
end

function s.b_op(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end