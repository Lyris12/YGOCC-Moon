--Anomalia delle Profondità
--Script by: XGlitchy30

local s,id,o=GetID()
function s.initial_effect(c)
	--ss
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:HOPT()
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--set
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DDD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:HOPT()
	e2:SetCondition(aux.TurnPlayerCond(1))
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not re then return false end
	local rc=re:GetHandler()
	return r&REASON_EFFECT==REASON_EFFECT and re:IsActiveType(TYPE_MONSTER) and rc and rc:IsType(TYPE_DRIVE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local en=Duel.GetEngagedCard(tp)
	if chk==0 then
		return en and en:IsMonster() and en:IsCanUpdateEnergy(-5,tp,REASON_EFFECT) and Duel.GetMZoneCount(tp)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	end
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local en=Duel.GetEngagedCard(tp)
	if en and en:IsMonster() and en:IsCanUpdateEnergy(-5,tp,REASON_EFFECT) then
		local eff,diff=en:UpdateEnergy(-5,tp,REASON_EFFECT,true,c)
		if not en:IsImmuneToEffect(eff) and diff~=0 and c:IsRelateToChain() and Duel.GetMZoneCount(tp)>0 then
			Duel.SpecialSummonRedirect(e,c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsSetCard(0x660) and c:IsSSetable()
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,nil,1,tp,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 and Duel.SSet(tp,g)>0 then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetDescription(aux.Stringid(id,2))
		g:GetFirst():RegisterEffect(e1)
	end
end