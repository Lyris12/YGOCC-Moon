--Numero C201: Ossidiana Incastonata Spektrale
--Scripted by: XGlitchy30
local s,id = GetID()

function s.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),3,4)
	c:EnableReviveLimit()
	--cannot link material
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CANNOT_BE_LINK_MATERIAL)
	e0:SetValue(1)
	c:RegisterEffect(e0)
	--search
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.thcon)
	e2:SetCost(s.sharedcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	--banish and damage
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_REMOVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(s.damcon)
	e3:SetCost(s.damcost)
	e3:SetTarget(s.damtg)
	e3:SetOperation(s.damop)
	c:RegisterEffect(e3)
	--
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
s.xyz_number=201
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

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_XYZ)
end
function s.filter(c)
	if not c:IsAbleToHand() then return false end
	return c:IsSetCard(0x95) and c:IsType(TYPE_SPELL) or c:IsType(TYPE_MONSTER) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsLevelBelow(4)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,id-1)
end
function s.rmfilter(c,tp)
	return c:IsFacedown() and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_EXTRA,nil,tp)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) and #g>0
	end
	e:SetLabel(0)
	local ct=e:GetHandler():RemoveOverlayCard(tp,1,#g,REASON_COST)
	if ct<=0 then return end
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,ct,0,0)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_EXTRA,nil,tp)
	if #g<=0 or ct>#g then return end
	local sg=g:RandomSelect(tp,ct)
	if #sg>0 and Duel.Remove(sg,POS_FACEDOWN,REASON_EFFECT)>0 and sg:IsExists(Card.IsLocation,1,nil,LOCATION_REMOVED) and Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_REMOVED,nil)>=5 then
		Duel.BreakEffect()
		Duel.Damage(1-tp,4000,REASON_EFFECT)
	end
end