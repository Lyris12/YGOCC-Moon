--Daylilly's Avenger
--created by Alastar Rainford, coded by Lyris
--Rescripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	if not s.progressive_id then
		s.progressive_id=id
	else
		s.progressive_id=s.progressive_id+1
	end
	
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.mfilter,3,3)
	--lock
	aux.RegisterMergedDelayedEventGlitchy(c,s.progressive_id,{EVENT_SUMMON_SUCCESS,EVENT_SPSUMMON_SUCCESS},s.sumfilter,id,LOCATION_MZONE,nil,LOCATION_MZONE,nil,id+100,true)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CUSTOM+s.progressive_id)
	e1:SetTarget(s.tg)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	--negate
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_NEGATE|CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP|EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:OPT()
	e2:SetCondition(s.discon)
	e2:SetCost(s.discost)
	e2:SetTarget(s.distg)
	e2:SetOperation(s.disop)
	c:RegisterEffect(e2)
end
function s.sumfilter(c,e,tp,eg)
	local lc=e:GetHandler()
	if eg:IsContains(lc) or not lc:IsType(TYPE_LINK) then return false end
	local g=lc:GetLinkedGroup()
	return c:IsControler(1-tp) and (c:IsFacedown() or not c:IsRace(RACE_PLANT)) and g:IsExists(aux.FaceupFilter(Card.IsRace,RACE_PLANT),3,eg)
end

function s.mfilter(c)
	return c:IsLinkRace(RACE_PLANT) and not c:IsLinkType(TYPE_EFFECT)
end

function s.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_BLACK_GARDEN),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	if eg then
		local c=e:GetHandler()
		local g
		local sg=eg:Filter(aux.NOT(Card.HasFlagEffectLabel),nil,id+200,c:GetFieldID())
		if #sg>1 then
			g=sg:SelectSubGroup(tp,aux.SimultaneousEventGroupCheck,false,1,#sg,id+100,sg)
		else
			g=sg:Clone()
		end
		Duel.HintSelection(g)
		for tc in aux.Next(g) do
			tc:RegisterFlagEffect(id+200,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1,c:GetFieldID())
		end
		Duel.SetTargetCard(g)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if not g then return end
	local c=e:GetHandler()
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(STRING_CANNOT_ATTACK)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(STRING_CANNOT_TRIGGER)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		tc:RegisterEffect(e2)
	end
end

function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function s.cfilter(c,g,ec)
	return (g:IsContains(c) or c==ec) and not c:IsStatus(STATUS_BATTLE_DESTROYED)
end
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local lg=c:GetLinkedGroup()
	if chk==0 then return Duel.CheckReleaseGroup(REASON_COST,tp,s.cfilter,1,nil,lg,c) end
	local rg=Duel.SelectReleaseGroup(REASON_COST,tp,s.cfilter,1,1,nil,lg,c)
	Duel.Release(rg,REASON_COST)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToChain(ev) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToChain(ev) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end