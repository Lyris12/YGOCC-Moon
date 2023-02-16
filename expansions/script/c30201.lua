--Mantra GOD
--Automate ID

local scard,s_id=GetID()
function scard.initial_effect(c)
	--ONLY 1
	c:SetUniqueOnField(1,0,s_id)
	Card.IsMantra=Card.IsMantra or (function(tc) return tc:IsSetCard(0x7d0) or (tc:GetCode()>30200 and tc:GetCode()<30230) end)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetCondition(scard.spcon)
	e1:SetTarget(scard.sptg)
	e1:SetOperation(scard.spop)
	c:RegisterEffect(e1)
	--Prohibit
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_ANNOUNCE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(2,s_id)
	e2:SetCondition(scard.condition)
	e2:SetTarget(scard.target)
	e2:SetOperation(scard.operation)
	c:RegisterEffect(e2)
	--attack all
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_ATTACK_ALL)
	e3:SetValue(scard.atkfilter)
	c:RegisterEffect(e3)
	--destroy
	local e4=Effect.CreateEffect(c)
	e4:Desc(2)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCondition(scard.descon)
	e4:SetTarget(scard.destg)
	e4:SetOperation(scard.desop)
	c:RegisterEffect(e4)
end
function scard.spfilter(c)
	return c:IsMantra() and not c:IsCode(s_id)
end
function s.spcon(e,c)
	if c==nil then return true end
	if c:IsLocation(LOCATION_GRAVE) and c:IsHasEffect(EFFECT_NECRO_VALLEY) then return false end
	local tp=c:GetControler()
	local g=Duel.GetReleaseGroup(tp):Filter(scard.spfilter,nil)
	return g:CheckSubGroup(aux.mzctcheckrel,2,2,tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=Duel.GetReleaseGroup(tp):Filter(scard.spfilter,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local sg=g:SelectSubGroup(tp,aux.mzctcheckrel,false,2,2,tp)
	if #sg>0 then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end

function scard.condition(e,tp,eg,ep,ev,re,r,rp)
	return tp~=Duel.GetTurnPlayer()
end
function scard.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
	local ac=Duel.AnnounceCard(tp)
	Duel.SetTargetParam(ac)
	Duel.SetOperationInfo(0,CATEGORY_ANNOUNCE,nil,0,tp,ANNOUNCE_CARD)
end
function scard.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ac=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	c:SetHint(CHINT_CARD,ac)
	--forbidden
	local rct = Duel.GetTurnPlayer()==tp and 2 or 1
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EFFECT_FORBIDDEN)
	e1:SetTargetRange(0x7f,0x7f)
	e1:SetTarget(scard.bantg)
	e1:SetLabel(ac)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_SELF_TURN,rct)
	Duel.RegisterEffect(e1,tp)
end
function scard.bantg(e,c)
	return c:IsCode(e:GetLabel())
end

function scard.atkfilter(e,c)
	return c:GetSummonType()&SUMMON_TYPE_SPECIAL==SUMMON_TYPE_SPECIAL
end

function scard.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return bc and bc:GetSummonType()&SUMMON_TYPE_SPECIAL==SUMMON_TYPE_SPECIAL
end
function scard.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc end
	Duel.SetCardOperationInfo(bc,CATEGORY_DESTROY)
end
function scard.desop(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
