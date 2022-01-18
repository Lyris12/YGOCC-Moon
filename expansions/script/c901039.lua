--Diadema di Smeraldo Spektrale
--Scripted by: XGlitchy30
local s,id = GetID()

function s.initial_effect(c)
	--synchro summon
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.FilterBoolFunction(Card.IsSetCard,0x27a),1)
	c:EnableReviveLimit()
	--cannot link material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--counters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_COUNTER)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--remove overlay replace
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_OVERLAY_REMOVE_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.rcon)
	e2:SetOperation(s.rop)
	c:RegisterEffect(e2)
	--extra xyz mats
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_XYZ_MATERIAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_HAND,0)
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x27a))
	e3:SetValue(s.xyzval)
	c:RegisterEffect(e3)
	--check summons
	if not s.global_check then
		s.global_check=true
		local g1=Effect.CreateEffect(c)
		g1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		g1:SetCode(EVENT_SUMMON_SUCCESS)
		g1:SetOperation(s.regop)
		Duel.RegisterEffect(g1,0)
		local g2=g1:Clone()
		g2:SetCode(EVENT_SPSUMMON_SUCCESS)
		Duel.RegisterEffect(g2,0)
		local g3=g1:Clone()
		g3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
		Duel.RegisterEffect(g3,0)
	end
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetOwner()
	for p=0,1 do
		if eg:IsExists(s.counterfilter,1,c,p) then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.counterfilter(c,p)
	return not c:IsAttribute(ATTRIBUTE_DARK) and c:GetSummonPlayer()==p
end
function s.sharedcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id)<=0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.sumlimit)
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	Duel.RegisterEffect(e2,tp)
	local e3=e1:Clone()
	e3:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	Duel.RegisterEffect(e3,tp)
	local e4=Effect.CreateEffect(e:GetHandler())
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_OATH)
	e4:SetDescription(aux.Stringid(id,4))
	e4:SetReset(RESET_PHASE+PHASE_END)
	e4:SetTargetRange(1,0)
	Duel.RegisterEffect(e4,tp)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end

function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.cfilter(c,tp,sg)
	sg:AddCard(c)
	local res=c:IsType(TYPE_MONSTER) and c:IsSetCard(0x27a) and c:IsAbleToRemoveAsCost() and (#sg<2 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,sg,tp,sg) or #sg>=2 and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,sg))
	sg:RemoveCard(c)
	return res
end
function s.tdfilter(c)
	if not c:IsAbleToDeck() then return false end
	return c:IsType(TYPE_SYNCHRO+TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK) or c:IsType(TYPE_SPELL) and c:IsSetCard(0x95)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then
		local sg=Group.CreateGroup()
		return s.sharedcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil,tp,sg)
	end
	s.sharedcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local sg=Group.CreateGroup()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,nil,tp,sg)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g2=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,g1,tp,sg)
	g1:Merge(g2)
	if #g1>0 then
		Duel.Remove(g1,POS_FACEUP,REASON_COST)
	end
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return (sumtype&SUMMON_TYPE_LINK)==SUMMON_TYPE_LINK and (not c:IsType(TYPE_LINK) or not c:IsSetCard(0x27a))
end
function s.ctfilter(c,ct)
	return c:IsFaceup() and c:IsCanAddCounter(0x127a,ct,true)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res = e:GetLabel()==1 or Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil)
		e:SetLabel(0)
		return res and Duel.IsExistingMatchingCard(s.ctfilter,tp,LOCATION_ONFIELD,0,1,nil,1)
	end
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	local fg=Duel.GetMatchingGroup(s.ctfilter,tp,LOCATION_ONFIELD,0,nil,1)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,fg,1,0x127a,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,nil)
	if #g<=0 then return end
	if Duel.SendtoDeck(g,nil,2,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK+LOCATION_EXTRA) then
		aux.ShuffleCheck(g)
		local ct=g:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		if ct>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
			local sg=Duel.SelectMatchingCard(tp,s.ctfilter,tp,LOCATION_ONFIELD,0,1,1,nil,ct)
			if #sg>0 then
				sg:GetFirst():AddCounter(0x127a,ct,true)
			end
		end
	end
end

function s.rcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_COST)~=0 and re:IsActivated()
		and re:IsActiveType(TYPE_XYZ) and ep==e:GetOwnerPlayer() and (ev==1 or ev==2 or ev==3)
		and Duel.IsCanRemoveCounter(tp,1,0,0x127a,ev,REASON_COST)
end
function s.rop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RemoveCounter(tp,1,0,0x127a,ev,REASON_COST)
	return ev
end

function s.xyzval(e,c,xyzc)
	return xyzc:IsRank(2) and xyzc:IsAttribute(ATTRIBUTE_DARK) and xyzc:IsSetCard(0x48) and xyzc:IsLocation(LOCATION_EXTRA)
end