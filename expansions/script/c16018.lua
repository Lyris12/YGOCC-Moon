--Paracyclissavior of Future, Starrain

local s,id=GetID()
function s.initial_effect(c)
	c:SetSPSummonOnce(id)
	--fusion summon
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.ffilter,3,false)
	aux.AddContactFusionProcedureGlitchy(c,0,false,SUMMON_TYPE_FUSION,Card.IsAbleToDeckOrExtraAsCost,LOCATION_MZONE,0,nil,s.matop)
	--Trigger Effect
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(aux.FusionSummonedCond)
	e1:SetCost(aux.LabelCost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--direct attack
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.dacon)
	e2:SetCost(s.dacost)
	e2:SetOperation(s.daop)
	c:RegisterEffect(e2)
end
s.material_setcode=0x308
function s.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x308) and c:GetLevel()>=8
		and (not sg or not sg:IsExists(Card.IsFusionCode,1,c,c:GetFusionCode()))
end
function s.matop(g,e,tp,eg,ep,ev,re,r,rp,c)
	local cg=g:Filter(Card.IsFacedown,nil)
	if cg:GetCount()>0 then
		Duel.ConfirmCards(1-c:GetControler(),cg)
	end
	return aux.PlaceCardsOnDeckBottom(tp,g,REASON_COST|REASON_FUSION|REASON_MATERIAL)
end

function s.cfilter(c)
	return c:IsSetCard(0x308) and c:IsAbleToGraveAsCost()
end
function s.tsfilter(c,tp)
	return not c:IsCanTurnSetGlitchy(tp) and c:IsFaceup()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,nil,tp)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return #g>0 and Duel.IsPlayerCanDiscardDeckAsCost(tp,1)
	end
	e:SetLabel(0)
	local tab={}
	for ct=#g,1,-1 do
		if Duel.IsPlayerCanDiscardDeckAsCost(tp,ct) then
			for i=1,ct do
				table.insert(tab,i)
			end
			break
		end
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NUMBER)
	local n=Duel.AnnounceNumber(tp,table.unpack(tab))
	local ct=Duel.DiscardDeck(tp,n,REASON_COST)
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,ct,1-tp,LOCATION_MZONE)
	
	local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local n2=Duel.GetMatchingGroupCount(s.tsfilter,tp,0,LOCATION_MZONE,nil,tp)
	local ct2 = #g-ct+n2
	if ct2>0 then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g2,ct2,1-tp,LOCATION_MZONE)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetTargetParam()
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,nil,tp)
	if ct<=#g then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSITION)
		local ng=g:Select(tp,ct,ct,nil)
		if #ng>0 then
			Duel.HintSelection(ng)
			Duel.ChangePosition(ng,POS_FACEDOWN_DEFENSE)
		end
	end
	local sg=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
	for tc in aux.Next(sg) do
		local e1=Effect.CreateEffect(c)
		e1:Desc(2)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCondition(s.limcon)
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		else
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,3)
		end
		e1:SetLabel(Duel.GetTurnCount(),tp)
		tc:RegisterEffect(e1)
		--
		local e2=Effect.CreateEffect(c)
		e2:Desc(3)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_BE_FUSION_MATERIAL)
		e2:SetCondition(s.limcon2)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UNRELEASABLE_SUM)
		tc:RegisterEffect(e3)
		local e4=e2:Clone()
		e4:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		tc:RegisterEffect(e4)
	end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE):Filter(Card.IsFaceup,nil)
	if #g>0 then
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end
end
function s.limcon(e)
	local ct,tp=e:GetLabel()
	return Duel.GetTurnCount()>ct and Duel.GetTurnPlayer()==1-tp
end
function s.limcon2(e)
	return e:GetHandler():IsPosition(POS_FACEDOWN_DEFENSE)
end

function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsAbleToEnterBP()
end
function s.dafilter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToGraveAsCost()
end
function s.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.dafilter,tp,LOCATION_EXTRA,0,3,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.dafilter,tp,LOCATION_EXTRA,0,3,3,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() then
		local e1=Effect.CreateEffect(c)
		e1:Desc(4)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end