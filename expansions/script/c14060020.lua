--终影魔 辉烬
local m=14060020
local cm=_G["c"..m]
function cm.initial_effect(c)
	--link summon
	aux.AddLinkProcedure(c,cm.matfilter,4,4,cm.lcheck)
	c:EnableReviveLimit()
	--base attack
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_SET_BASE_ATTACK)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(cm.atkval)
	c:RegisterEffect(e0)
	--spsummon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(0,1)
	e1:SetCondition(cm.sumcon)
	e1:SetTarget(cm.sumlimit)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e2)
	--to deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(m,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(cm.tdcon)
	e3:SetTarget(cm.tdtg)
	e3:SetOperation(cm.tdop)
	c:RegisterEffect(e3)
	--cannot be fusion material
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e4:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
function cm.matfilter(c)
	return c:IsLinkCode(14060014,14060013,14060012,14060006)
end
function cm.lcheck(g,lc)
	return g:IsExists(Card.IsLinkCode,1,nil,14060014) and g:IsExists(Card.IsLinkCode,1,nil,14060013) and g:IsExists(Card.IsLinkCode,1,nil,14060012) and g:IsExists(Card.IsLinkCode,1,nil,14060006)
end
function cm.atkfilter(c,e,tp)
	return c:IsSetCard(0x1406) and c:IsFaceup()
end
function cm.atkval(e,c)
	return Duel.GetMatchingGroupCount(cm.atkfilter,c:GetControler(),LOCATION_DECK+LOCATION_EXTRA,0,nil)*200
end
function cm.cfilter(c)
	return c:IsFaceup() and c:IsCode(14060019)
end
function cm.sumcon(e,c)
	local tp=e:GetHandlerPlayer()
	return Duel.IsExistingMatchingCard(cm.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
function cm.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	return e:GetHandler():GetBaseAttack()>c:GetBaseAttack() and c:GetBaseAttack()>=0
end
function cm.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function cm.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,e:GetHandler())
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	Duel.SetChainLimit(aux.FALSE)
end
function cm.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_MESSAGE,tp,aux.Stringid(m,1))
	Duel.Hint(HINT_MESSAGE,1-tp,aux.Stringid(m,1))
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE+LOCATION_REMOVED,aux.ExceptThisCard(e))
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
end