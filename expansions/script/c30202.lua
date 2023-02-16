--Mantra Kid
--Automate ID

local scard,s_id=GetID()

function scard.initial_effect(c)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
    --LV+
    local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCustomCategory(CATEGORY_LVCHANGE)
    e1:SetType(EFFECT_TYPE_IGNITION)
    e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e1:SetTarget(scard.lvtg)
    e1:SetOperation(scard.lvop)
    e1:SetCountLimit(1)
    c:RegisterEffect(e1)
	--SS from hand
	local e3=Effect.CreateEffect(c)
	e3:Desc(1)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(scard.sp2con)
	e3:SetTarget(scard.sp2tg)
	e3:SetOperation(scard.sp2op)
	e3:SetCountLimit(1,s_id+EFFECT_COUNT_CODE_OATH)
	c:RegisterEffect(e3)
	--SS from Grave
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DDD)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(scard.spcon)
	e4:SetTarget(scard.sptg)
	e4:SetOperation(scard.spop)
	e4:SetCountLimit(1,s_id)
	c:RegisterEffect(e4)
end
function scard.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:HasLevel() end
	Duel.SetCustomOperationInfo(0,CATEGORY_LVCHANGE,c,1,c:GetControler(),c:GetLocation(),2)
end
function scard.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetValue(2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end

function scard.spfilter(c)
	return c:IsMonster() and c:IsMantra() and c:IsAbleToGraveAsCost()
end
function scard.sp2con(e,c)
	if c==nil then return true end
	local tp=e:GetHandlerPlayer()
	local rg=Duel.GetMatchingGroup(scard.spfilter,tp,LOCATION_HAND,0,e:GetHandler())
	return not Duel.PlayerHasFlagEffect(tp,s_id) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and #rg>0
end
function scard.sp2tg(e,tp,eg,ep,ev,re,r,rp,c)
	local c=e:GetHandler()
	local rg=Duel.GetMatchingGroup(scard.spfilter,tp,LOCATION_HAND,0,c)
	local g=rg:Select(tp,1,1,nil)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function scard.sp2op(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.SendtoGrave(g,REASON_COST)
	Duel.RegisterFlagEffect(tp,s_id,RESET_PHASE+PHASE_END,0,1)
	g:DeleteGroup()
end

function scard.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=re:GetHandler()
	return not Duel.PlayerHasFlagEffect(tp,s_id) and rc and rc:IsMantra() and c:IsReason(REASON_EFFECT|REASON_COST)
end
function scard.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.RegisterFlagEffect(tp,s_id,RESET_PHASE+PHASE_END,0,1)
	Duel.SetCardOperationInfo(c,CATEGORY_SPECIAL_SUMMON)
end
function scard.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToChain() then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
