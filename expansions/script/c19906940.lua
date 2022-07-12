--Paintress Mahdia
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Link summon prcoedure
	   aux.AddLinkProcedure(c,nil,2,99,s.lcheck)
  --special summon
	--local e0=Effect.CreateEffect(c)
	--e0:SetType(EFFECT_TYPE_FIELD)
	--e0:SetDescription(aux.Stringid(6666,6))
	--e0:SetCode(EFFECT_SPSUMMON_PROC)
	--e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	--e0:SetRange(LOCATION_EXTRA)
	--e0:SetCondition(s.spcon)
	--e0:SetOperation(s.spop)
	--e0:SetValue(SUMMON_TYPE_LINK)
	--c:RegisterEffect(e0)
   --cannot be target/battle indestructable
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD)
	e0:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e0:SetRange(LOCATION_MZONE)
	e0:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e0:SetTarget(s.tgtg)
	e01:SetValue(1)
	c:RegisterEffect(e0)
  local e1=e0:Clone()
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e1)
	local e2=e0:Clone()
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetTarget(s.tgtg3)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
--atkup
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16000443,0))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.tdcon)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
function s.mfilter(c)
	return  not c:IsLinkType(TYPE_EFFECT)
end
function s.lcheck(g,lc)
	return g:IsExists(Card.IsSetCard,1,nil,0xc50)
end
function s.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xc50) and c:IsAbleToRemoveAsCost()
end
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,3,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,3,3,nil)
	Duel.Remove(g,POS_FACEUP,REASON_LINK)
	e:GetHandler():SetMaterial(g:Filter(Card.IsLocation,nil,LOCATION_REMOVED))
end
function s.tgtg(e,c)
	return  e:GetHandler()==c or (not c:IsType(TYPE_EFFECT) and c:IsType(TYPE_MONSTER) and e:GetHandler():GetLinkedGroup():IsContains(c))
end
function s.tgtg3(e,c)
 return e:GetHandler()==c or (not c:IsType(TYPE_EFFECT) and c:IsType(TYPE_MONSTER) and e:GetHandler():GetLinkedGroup():IsContains(c))
end
 
function s.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_ALL,LOCATION_REMOVED)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_REMOVED,0):Filter(s.filter,nil,c:GetMaterial())
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT)
	local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)
	if c:IsFaceup() and c:IsRelateToEffect(e) then
	Duel.Recover(tp,ct*300,REASON_EFFECT)
	
	end
end
function s.filter(c,mg)
	return not mg:IsContains(c)
end
