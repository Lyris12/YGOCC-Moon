--Lich-Lord Xe'enafae
local cid,id=GetID()
function cid.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,cid.ffilter,5,false)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	c:SetUniqueOnField(1,0,id)
	--Once per turn, during your Standby Phase, if there is no "Lich-Lord's Phylactery" in your GY: Destroy this card, and if you do, destroy all other cards on the field, except "Zombie World", then both players draw cards until they have 7 in their hand. Other cards destroyed by this effect cannot activate their effects.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1)
	e5:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e5:SetCondition(function(e) return not Duel.IsExistingMatchingCard(cid.cfilter,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil) and Duel.GetTurnPlayer()==e:GetHandlerPlayer() end)
	e5:SetTarget(cid.destg)
	e5:SetOperation(cid.desop)
	c:RegisterEffect(e5)
	--copy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(9163835,5))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetCondition(cid.cpcon)
	e3:SetTarget(cid.cptg)
	e3:SetOperation(cid.cpop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCondition(cid.cpcon1)
	c:RegisterEffect(e4)
	--Prevent Activation
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(cid.cfilter,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil) end)
	e2:SetValue(cid.aclimit)
	c:RegisterEffect(e2)
end
function cid.ffilter(c,fc,sub,mg,sg)
	return c:IsRace(RACE_ZOMBIE) and (not sg or #sg<2 or sg:IsExists(Card.IsFusionSetCard,2,nil,0x2e7))
end
function cid.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(aux.OR(Card.IsFacedown,aux.NOT(Card.IsCode)),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,4064256)+e:GetHandler()
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
function cid.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	local g=Duel.GetMatchingGroup(aux.OR(Card.IsFacedown,aux.NOT(Card.IsCode)),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,4064256)
	local ct=Duel.Destroy(g,REASON_EFFECT)
	for tc in aux.Next(g:Filter(aux.NOT(Card.IsOnField),nil)) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
	if ct==#g then
		Duel.BreakEffect()
		Duel.Draw(tp,7-Duel.GetFieldGroupCount(tp,LOCATION_HAND,0),REASON_EFFECT)
		Duel.Draw(1-tp,7-Duel.GetFieldGroupCount(tp,0,LOCATION_HAND),REASON_EFFECT)
	end
end
function cid.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_MZONE and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRace(RACE_ZOMBIE)
end
function cid.cfilter(c)
	return c:IsCode(91630827)
end
function cid.cpcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil) and not Duel.IsPlayerAffectedByEffect(tp,91630825)
end
function cid.cpcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(cid.cfilter,e:GetHandler():GetControler(),LOCATION_GRAVE,0,1,nil) and Duel.IsPlayerAffectedByEffect(tp,91630825)
end
function cid.copytg(c)
	return c:IsRace(RACE_ZOMBIE) and not c:IsCode(id)
end
function cid.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc~=e:GetHandler() and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and cid.copytg(chkc) end
	if chk==0 then return Duel.IsExistingTarget(cid.copytg,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,2,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,cid.copytg,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,2,2,e:GetHandler())
end
function cid.cpop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	if tg and c:IsRelateToEffect(e) and c:IsFaceup() then
		for tc in aux.Next(tg) do
			local code=tc:GetOriginalCode()
			local cid1=0
			if not tc:IsType(TYPE_TRAPMONSTER) then
				cid1=c:CopyEffect(code,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			end
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_PHASE+PHASE_END)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
			e2:SetCountLimit(1)
			e2:SetRange(LOCATION_MZONE)
			e2:SetReset(RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_END)
			e2:SetLabel(cid1)
			e2:SetOperation(cid.rstop)
			c:RegisterEffect(e2)
		end
	end
end
function cid.rstop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local cid=e:GetLabel()
	if cid~=0 then c:ResetEffect(cid,RESET_COPY) end
	Duel.HintSelection(Group.FromCards(c))
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end