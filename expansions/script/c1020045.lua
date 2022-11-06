--Divinità Bushido Fenice Bruciante
--Script by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--protection
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetCode(EFFECT_IMMUNE_EFFECT)
	e0:SetRange(LOCATION_MZONE)
	e0:SetValue(s.efilter)
	c:RegisterEffect(e0)
	--tribute summon proc
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetCondition(s.otcon)
	e2:SetOperation(s.otop)
	e2:SetValue(SUMMON_TYPE_ADVANCE+1)
	c:RegisterEffect(e2)
	--NS/Special Summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DDD)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--pos
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.poscon)
	e3:SetTarget(s.postg)
	e3:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e3)
	--SS
	c:LeaveTrigger(false,2,CATEGORY_SPECIAL_SUMMON,false,false,nil,nil,aux.SSTarget(s.spfilter,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE),aux.SSOperation(s.spfilter,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE))
end
function s.efilter(e,te)
	local tc=te:GetOwner()
	return te:IsActiveType(TYPE_MONSTER) and te:GetOwnerPlayer()==1-e:GetHandlerPlayer() and (tc:IsSummonType(SUMMON_TYPE_SPECIAL) or te:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL))
end

function s.otfilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsSetCard(0x4b0) and c:IsAbleToDeckOrExtraAsCost()
end
function s.otcon(e,c,minc)
	if c==nil then return true end
	if minc>0 or c:GetLevel()<=4 then return false end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_REMOVED,0,nil)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #mg>=3
end
function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=Duel.Select(HINTMSG_TODECK,false,tp,s.otfilter,tp,LOCATION_REMOVED,0,3,3,nil)
	Duel.HintSelection(sg)
	c:SetMaterial(sg)
	Duel.SendtoDeck(sg,nil,SEQ_DECKSHUFFLE,REASON_SUMMON+REASON_MATERIAL)
end

function s.descon(e,tp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_ADVANCE+1
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,1-tp,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_MZONE,nil)
	if #sg>0 then
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

function s.poscon(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_NORMAL) and c:HasLevel()
end
function s.postg(e,c)
	return c:IsFaceup() and c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:HasLevel() and c:GetLevel()>e:GetHandler():GetLevel()
end

function s.spfilter(c)
	return c:IsSetCard(0x4b0) and c:HasLevel() and c:IsLevelBelow(7)
end