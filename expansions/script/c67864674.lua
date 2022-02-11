--VECTOR Frame: Ryva
--Scripted by Boos
local cod,id=GetID()
function cod.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(cod.spcon)
	c:RegisterEffect(e1)
	--tograve
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCost(cod.atcost)
	e2:SetTarget(cod.attg)
	e2:SetOperation(cod.atop)
	c:RegisterEffect(e2)
	--send to deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_START)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(cod.condition)
	e3:SetTarget(cod.target)
	e3:SetOperation(cod.operation)
	c:RegisterEffect(e3)
end
function cod.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(6) and c:IsSetCard(0x2a6)
end
function cod.spcon(e,c)
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(cod.cfilter,c:GetControler(),LOCATION_MZONE,0,1,nil)
end
function cod.cfilter2(c)
	return c:IsSetCard(0x2a6) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
function cod.atcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.cfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,cod.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function cod.atfilter(c)
	return c:IsSetCard(0x2a6) and c:IsType(TYPE_MONSTER)
end
function cod.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(cod.atfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)
	local aat=Duel.AnnounceAttribute(tp,1,0xffff)
	e:SetLabel(aat)
end
function cod.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(cod.chgtg)
	e1:SetValue(e:GetLabel())
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function cod.chgtg(e,c)
	return c:IsSetCard(0x2a6)
end
function cod.condition(e,tp,eg,ep,ev,re,r,rp)
	local a,d=Duel.GetAttacker(),Duel.GetAttackTarget()
	if not d then return false end
	if a:IsControler(1-tp) then d,a=a,d end
	return a:IsFaceup() and a:IsSetCard(0x2a6) and d:IsFaceup() and a:GetAttribute()&d:GetAttribute()~=0
end
function cod.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	if chk==0 then return g:IsExists(Card.IsAbleToDeck,2,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,2,0,0)
end
function cod.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.FromCards(Duel.GetAttacker(),Duel.GetAttackTarget())
	if #g==2 and g:IsExists(aux.AND(Card.IsRelateToBattle,Card.IsAbleToDeck),2,nil) then Duel.SendtoDeck(g,nil,2,REASON_EFFECT) end
end
