--Ergoriesumazione Extra - Anagrapha
--Scripted by: XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,CARD_ANONYMIZE)
	--Change name
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetRange(LOCATION_DECK+LOCATION_HAND+LOCATION_GRAVE)
	e0:SetValue(CARD_ANONYMIZE)
	c:RegisterEffect(e0)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_RECOVER+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--anonymize
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.tkcost)
	e2:SetTarget(s.tktg)
	e2:SetOperation(s.tkop)
	c:RegisterEffect(e2)
end
function s.filter(c,typ,e)
	return c:IsFaceup() and c:IsCode(CARD_ANONYMIZE) and (typ==0 or c:IsType(typ)) and (not e or c:IsCanBeEffectTarget(e))
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsType,nil,TYPE_MONSTER)<=1
		and sg:FilterCount(Card.IsType,nil,TYPE_SPELL)<=1
		and sg:FilterCount(Card.IsType,nil,TYPE_TRAP)<=1
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	local typ=0
	if Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) then
		typ=typ|TYPE_MONSTER
	end
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,e:GetHandler()) then
		typ=typ|TYPE_SPELL
	end
	if Duel.IsPlayerCanDraw(tp,3) then
		typ=typ|TYPE_TRAP
	end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,1,e:GetHandler(),typ) end
	e:SetLabel(0)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_ONFIELD+LOCATION_GRAVE,LOCATION_ONFIELD+LOCATION_GRAVE,e:GetHandler(),typ,e)
	local sg=aux.SelectUnselectGroup(g,e,tp,1,3,s.rescon,1,tp,HINTMSG_TARGET)
	local lb=0
	for tc in aux.Next(sg) do
		lb=lb|tc:GetType()
	end
	lb=lb&0x7
	Duel.SetTargetCard(sg)
	if lb&TYPE_MONSTER>0 then
		e:SetLabel(e:GetLabel()|TYPE_MONSTER)
		local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	end
	if lb&TYPE_SPELL>0 then
		e:SetLabel(e:GetLabel()|TYPE_SPELL)
		Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
	end
	if lb&TYPE_TRAP>0 then
		e:SetLabel(e:GetLabel()|TYPE_TRAP)
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local lb=e:GetLabel()
	if lb==0 then return end
	if lb&TYPE_MONSTER>0 then
		getmetatable(e:GetHandler()).announce_filter={TYPE_TOKEN,OPCODE_ISTYPE,OPCODE_NOT}
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CODE)
		local ac=Duel.AnnounceCard(tp,table.unpack(getmetatable(e:GetHandler()).announce_filter))
		if ac>0 then
			local g=Duel.GetMatchingGroup(s.tdf,tp,0,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,nil,ac)
			if #g>0 then
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TODECK)
				local sg=g:Select(1-tp,1,1,nil)
				Duel.HintSelection(sg)
				if sg:GetFirst():IsLocation(LOCATION_HAND) or sg:GetFirst():IsFacedown() then
					Duel.ConfirmCards(tp,sg:GetFirst())
				end
				if Duel.SendtoDeck(sg,nil,SEQ_DECKBOTTOM,REASON_RULE)>0 then
					for p=0,1 do
						if sg:GetFirst():IsControler(p) and sg:GetFirst():IsLocation(LOCATION_DECK) then
							Duel.ShuffleDeck(p)
							break
						end
					end
				end
			end
		end
	end
	if lb&TYPE_SPELL>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		local g=Duel.SelectMatchingCard(tp,Card.IsFaceup,tp,LOCATION_ONFIELD,0,1,1,e:GetHandler())
		if #g>0 then
			local rc=g:GetFirst()
			local val=rc:GetOriginalCode()
			val=val-math.fmod(val,50)
			if val>0 and Duel.Recover(tp,val,REASON_EFFECT)>0 then
				Duel.BreakEffect()
				if Duel.GetLP(tp)>10000 then
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
					e1:SetProperty(EFFECT_FLAG_DELAY)
					e1:SetCode(EVENT_PHASE+PHASE_END)
					e1:SetCountLimit(1)
					e1:SetOperation(s.winop)
					Duel.RegisterEffect(e1,tp)
				end
			end
		end
	end
	if lb&TYPE_TRAP>0 and Duel.Draw(tp,3,REASON_EFFECT)==3 then
		local dg=Duel.GetOperatedGroup()
		Duel.ConfirmCards(1-tp,dg)
		local maxc=dg:GetMaxGroup(Card.GetOriginalCode):GetFirst()
		local minc=dg:GetMinGroup(Card.GetOriginalCode):GetFirst()
		local g=Group.CreateGroup()
		if maxc and maxc:IsLocation(LOCATION_HAND) then
			g:AddCard(maxc)
		end
		if minc and minc:IsLocation(LOCATION_HAND) then
			g:AddCard(minc)
		end
		if #g>0 then
			Duel.BreakEffect()
			Duel.SendtoDeck(g,nil,SEQ_DECKBOTTOM,REASON_EFFECT)
		end
	end
end
function s.tdf(c,code)
	return c:IsCode(code) and c:IsAbleToDeck()
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Win(1-tp,id)
end

function s.costfilter(c)
	return c:IsSetCard(0xca4) and c:IsAbleToRemoveAsCost()
end
function s.tkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return aux.bfgcost(e,tp,eg,ep,ev,re,r,rp,0) and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_COST)
	end
end
function s.nf(c)
	return (c:IsFaceup() or not c:IsOnField()) and not c:IsCode(CARD_ANONYMIZE)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_ONFIELD+LOCATION_GRAVE) and chkc:IsControler(1-tp) and s.nf(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.nf,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	Duel.SelectTarget(tp,s.nf,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,1,nil)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and (tc:IsFaceup() or tc:IsLocation(LOCATION_GRAVE)) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(CARD_ANONYMIZE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_OVERLAY)
		tc:RegisterEffect(e1)
	end
end