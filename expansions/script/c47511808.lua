--Deltaingranaggi Omega
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	local f0=Effect.CreateEffect(c)
	f0:SetType(EFFECT_TYPE_FIELD)
	f0:SetCode(EFFECT_SPSUMMON_PROC)
	f0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	f0:SetRange(LOCATION_EXTRA)
	f0:SetCondition(s.contactcon)
	f0:SetTarget(s.contacttg)
	f0:SetOperation(s.contactop)
	c:RegisterEffect(f0)
	--spsummon condition
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_SPSUMMON_CONDITION)
	e0:SetValue(s.splimit)
	c:RegisterEffect(e0)
	--protection
	c:EffectProtection()
	--search or activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetCustomCategory(CATEGORY_ACTIVATE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:HOPT()
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--negate
	c:Quick(false,1,CATEGORY_DISABLE,EFFECT_FLAG_CARD_TARGET,nil,nil,true,nil,aux.LabelCost,s.distg,s.disop)
	--tohand
	c:DestroyedTrigger(true,2,CATEGORY_TOHAND,nil,true,nil,nil,aux.SearchTarget(s.thfilter,1,LOCATION_GRAVE),aux.SearchOperation(s.thfilter,1,1,LOCATION_GRAVE))
end
function s.matfilter(c,fc)
	local tp=fc:GetControler()
	return c:IsAbleToDeckOrExtraAsCost() and c:IsCanBeFusionMaterial(fc,SUMMON_TYPE_SPECIAL) and c:IsFusionType(TYPE_SPELL+TYPE_TRAP) and c:IsFusionSetCard(0xfa6) and (not c:IsLocation(LOCATION_MZONE) or c:IsFaceup())
end
function s.contactcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil,c)
	return #g>=3 and Duel.GetLocationCount(tp,LOCATION_MZONE)>-2 and g:CheckSubGroup(aux.mzctcheck,3,3,tp)
end
function s.contacttg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local sg=Duel.GetMatchingGroup(s.matfilter,tp,LOCATION_ONFIELD+LOCATION_HAND,0,nil,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FMATERIAL)
	local g=sg:SelectSubGroup(tp,aux.mzctcheck,true,3,3,tp)
	if #g>0 then
		g:KeepAlive()
		e:SetLabelObject(g)
		return true
	end
	return false
end
function s.contactop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	c:SetMaterial(g)
	local cg=g:Filter(Card.IsFacedown,nil)
	if #cg>0 then
		Duel.ConfirmCards(1-tp,cg)
	end
	Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
	g:DeleteGroup()
end
function s.splimit(e,se,sp,st)
	return e:GetHandler():GetLocation()~=LOCATION_EXTRA
end

function s.thfilter(c)
	return c:IsST() and c:IsSetCard(0xfa6)
		and (c:IsAbleToHand() or (c:IsType(TYPE_CONTINUOUS+TYPE_FIELD) and c:GetActivateEffect():IsActivatable(tp,true,true) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)))
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetCustomOperationInfo(0,CATEGORY_ACTIVATE,nil,1,tp,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	Duel.ResetFlagEffect(tp,15248873)
	local tc=g:GetFirst()
	if tc then
		local te=tc:GetActivateEffect()
		local b1=tc:IsAbleToHand()
		if e:GetLabel()==1 then Duel.RegisterFlagEffect(tp,15248873,RESET_CHAIN,0,1) end
		local b2=tc:IsType(TYPE_CONTINUOUS+TYPE_FIELD) and te:IsActivatable(tp,true,true) and (tc:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		Duel.ResetFlagEffect(tp,15248873)
		if b1 and (not b2 or Duel.SelectOption(tp,1190,1150)==0) then
			Duel.Search(tc,tp)
		else
			local loc=LOCATION_SZONE
			if tc:IsType(TYPE_FIELD) then
				loc=LOCATION_FZONE
				local fc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
				if fc then
					Duel.SendtoGrave(fc,REASON_RULE)
					Duel.BreakEffect()
				end
			end
			Duel.MoveToField(tc,tp,tp,loc,POS_FACEUP,true)
			te:UseCountLimit(tp,1,true)
			local tep=tc:GetControler()
			local cost=te:GetCost()
			if cost then cost(te,tep,eg,ep,ev,re,r,rp,1) end
			if tc:IsType(TYPE_FIELD) then
				Duel.RaiseEvent(tc,4179255,te,0,tp,tp,Duel.GetCurrentChain())
			end
		end
	end
end

function s.costfilter(c)
	return c:IsST() and c:IsSetCard(0xfa6) and c:IsDiscardable()
end
function s.disfilter(c)
	return c:IsST() and aux.NegateAnyFilter(c)
end
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and s.disfilter(chkc) end
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
			and Duel.IsExistingTarget(s.disfilter,tp,0,LOCATION_ONFIELD,1,nil)
	end
	e:SetLabel(0)
	local max=math.min(2,Duel.GetTargetCount(s.disfilter,tp,0,LOCATION_ONFIELD,nil))
	if max==0 then return end
	local ct=Duel.DiscardHand(tp,s.costfilter,1,max,REASON_COST+REASON_DISCARD,nil)
	if ct>0 then
		Duel.HintMessage(tp,HINTMSG_DISABLE)
		local g=Duel.SelectTarget(tp,s.disfilter,tp,0,LOCATION_ONFIELD,ct,ct,nil)
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,#g,1-tp,LOCATION_ONFIELD)
	end
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards()
	if #g==0 then return end
	local ng=Group.CreateGroup()
	for tc in aux.Next(g) do
		local e1,e2=Duel.Negate(tc,e)
		if not tc:IsImmuneToEffect(e1) and not tc:IsImmuneToEffect(e2) then
			ng:AddCard(tc)
		end
	end
	if #ng>0 then
		local sg=ng:Filter(Card.IsCanTurnSet,nil)
		if #sg>0 then
			Duel.BreakEffect()
			local c=e:GetHandler()
			local fid=e:GetFieldID()
			local rg=Group.CreateGroup()
			for rc in aux.Next(sg) do
				if Duel.ChangePosition(rc,POS_FACEDOWN)>0 then
					rc:CancelToGrave()
					if rc:IsFacedown() then
						Debug.Message(0)
						rg:AddCard(rc)
						rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,EFFECT_FLAG_SET_AVAILABLE,1,fid)
						local e1=Effect.CreateEffect(c)
						e1:SetType(EFFECT_TYPE_FIELD)
						e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
						e1:SetCode(EFFECT_CANNOT_ACTIVATE)
						e1:SetTargetRange(0,1)
						e1:SetValue(s.aclimit)
						e1:SetLabel(fid)
						e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN)
						Duel.RegisterEffect(e1,tp)
					end
				end
			end
			Duel.RaiseEvent(rg,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
		end
	end
end
function s.aclimit(e,re,tp)
	local rc=re:GetHandler()
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and rc:HasFlagEffect(id) and rc:GetFlagEffectLabel(id)==e:GetLabel() and not rc:IsImmuneToEffect(e)
end

function s.thfilter(c)
	return c:IsST() and c:IsSetCard(0xfa6)
end