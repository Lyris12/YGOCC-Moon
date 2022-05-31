--Flauros, Bestia IX dell'Archivio del Mondo
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCodeFunRep(c,29493149,s.materialf,1,63,true,true)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--extra materials
	local e2=Effect.CreateEffect(c)
	e2:Desc(0)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_GLITCHY_EXTRA_FUSION_MATERIAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetLabel(4)
	e2:SetTarget(s.mttg)
	e2:SetValue(s.mtval)
	c:RegisterEffect(e2)
	local e2x=Effect.CreateEffect(c)
	e2x:SetType(EFFECT_TYPE_FIELD)
	e2x:SetCode(id)
	e2x:SetRange(LOCATION_MZONE)
	e2x:SetTargetRange(0,LOCATION_MZONE)
	c:RegisterEffect(e2x)
	--ss
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+100)
	e3:SetCost(s.spcost)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
function s.materialf(c)
	return c:IsFusionType(TYPE_MONSTER) and c:IsFusionType(TYPE_FUSION) and c:IsFusionSetCard(0x29a)
end

function s.efilter(e,te)
	return te:GetOwnerPlayer()~=e:GetHandlerPlayer() and te:IsActivated()
end

function s.mttg(e,c)
	return c:IsFaceup() and c:IsControler(1-e:GetHandlerPlayer())
end
function s.mtval(e,c,tp,mg)
	if not c then return false, 1 end
	return c:IsSetCard(0x29a) and c:IsType(TYPE_FUSION), 99
end

function s.cf(c,tp)
	return c:IsSetCard(0x29a) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost() and Duel.IsExists(false,s.cf2,tp,LOCATION_GRAVE,0,2,c)
end
function s.cf2(c)
	return c:IsSetCard(0x29a) and c:IsType(TYPE_SPELL) and c:IsAbleToRemoveAsCost()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExists(false,s.cf,tp,LOCATION_GRAVE,0,1,nil,tp) end
	local g1=Duel.Select(HINTMSG_REMOVE,false,tp,s.cf,tp,LOCATION_GRAVE,0,1,1,nil,tp)
	local g2=Duel.Select(HINTMSG_REMOVE,false,tp,s.cf2,tp,LOCATION_GRAVE,0,2,2,nil)
	g1:Merge(g2)
	if #g1>0 then
		Duel.Remove(g1,POS_FACEUP,REASON_COST)
	end
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end