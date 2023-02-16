--Shocker Tempesta
--Scripted by: XGlitchy30

local s,id=GetID()

function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetRange(LOCATION_HAND)
	e1:SetTargetRange(POS_FACEUP_DEFENSE,0)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--destroy
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,{id,1})
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	--disable
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_ABSOLUTE_TARGET)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	e3:SetTarget(s.disfilter)
	c:RegisterEffect(e3)
	local e3x=Effect.CreateEffect(c)
	e3x:SetType(EFFECT_TYPE_FIELD)
	e3x:SetProperty(EFFECT_FLAG_ABSOLUTE_TARGET)
	e3x:SetCode(EFFECT_DISABLE_TRAPMONSTER)
	e3x:SetRange(LOCATION_MZONE)
	e3x:SetTargetRange(LOCATION_MZONE,0)
	e3x:SetTarget(s.disfilter)
	c:RegisterEffect(e3x)
	--set
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetCustomCategory(CATEGORY_SET)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,{id,2})
	e4:SetCondition(s.tgcon)
	e4:SetTarget(s.tgtg)
	e4:SetOperation(s.tgop)
	c:RegisterEffect(e4)
	local e4x=e4:Clone()
	e4x:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4x)
end

function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	if not Duel.IsExistingMatchingCard(aux.Faceup(Card.IsST),tp,LOCATION_ONFIELD,0,1,nil) then return false end
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,false,false,POS_FACEUP)
	or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,false,false,POS_FACEUP,1-tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local b1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,false,false,POS_FACEUP)
	local b2=Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 and e:GetHandler():IsCanBeSpecialSummoned(e,1,tp,false,false,POS_FACEUP,1-tp)
	if not b1 and not b2 then return false end
	local sel=aux.Option(e,tp,1,b1,b2)
	if sel==0 then
		e:SetTargetRange(POS_FACEUP_DEFENSE,0)
	else
		e:SetTargetRange(POS_FACEUP_DEFENSE,1)
	end
	return true
end

function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+1
end
function s.filter(c,p)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsControler(p)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e:GetHandler():GetOwner())
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0,nil)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,e:GetHandler():GetOwner())
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end

function s.disfilter(e,c)
	return c~=e:GetHandler() and (c:GetType()&(TYPE_SPELL+TYPE_FIELD)==TYPE_SPELL+TYPE_FIELD or c:IsST() and c:IsType(TYPE_CONTINUOUS))
end

--set
function s.tgcfilter(c,tp)
	return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_THUNDER) and c:IsControler(tp)
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return eg and eg:IsExists(s.tgcfilter,1,e:GetHandler(),tp)
end
function s.setfilter(c)
	return (c:IsType(TYPE_ST) and c:IsType(TYPE_CONTINUOUS) or c:GetType()&TYPE_SPELL+TYPE_FIELD==TYPE_SPELL+TYPE_FIELD) and c:IsSSetable()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil)
	end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
	Duel.SetCustomOperationInfo(0,CATEGORY_SET,nil,1,tp,LOCATION_GRAVE)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local _,ct=Duel.SSet(tp,tc)
		if ct<=0 then return end
		if tc:IsType(TYPE_TRAP) then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end