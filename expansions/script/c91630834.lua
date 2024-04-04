--[[
Lich-Lord's Black Book
Libro Nero del Signore-Lich
Card Author: Walrus
Scripted by: XGlitchy30
]]

local s,id=GetID()
function s.initial_effect(c)
	--You can only control 1 "Lich-Lord's Black Book".
	c:SetUniqueOnField(1,0,id)
	c:Activation()
	--[[Each time a "Lich-Lord" monster(s) you control is destroyed by a "Lich-Lord" card or effect, you can immediately take 1 Level 4 or lower Zombie monster from your Deck,
	and either add it to your hand or send it to the GY.]]
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.regcon)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS|EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_SOLVED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(s.condition_afterchain)
	e3:SetOperation(s.operation_afterchain)
	c:RegisterEffect(e3)
	--[[If this card is in the GY, except the turn it was sent there, and you have "Lich-Lord's Phylactery" is in your GY:
	You can target 1 of your banished Zombie monsters, or 1 of your banished "Lich-Lord" Spell/Traps; shuffle this card into your Deck, and if you do, add that target to your hand.]]
	local e4=Effect.CreateEffect(c)
	e4:Desc(0)
	e4:SetCategory(CATEGORY_TODECK|CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:HOPT()
	e4:SetFunctions(s.thcon,nil,s.thtg,s.thop)
	c:RegisterEffect(e4)
	--During your End Phase, if you do not have "Lich-Lord's Phylactery" in your GY, destroy this card.
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCode(EFFECT_SELF_DESTROY)
	e5:SetCondition(s.descon)
	c:RegisterEffect(e5)
	aux.RegisterTriggeringArchetypeCheck(c,ARCHE_LICH_LORD)
end

--E2
function s.filter(c,tp,re)
	if not (c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousSetCard(ARCHE_LICH_LORD) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)) then return false end
	if c:IsReason(REASON_BATTLE) then
		return c:GetReasonCard():IsSetCard(ARCHE_LICH_LORD)
	else
		return re and aux.CheckArchetypeReasonEffect(s,re,ARCHE_LICH_LORD)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp,re)
		and (not re or not re:IsHasType(EFFECT_TYPE_ACTIONS) or re:IsHasType(EFFECT_TYPE_CONTINUOUS))
end
function s.thfilter(c)
	return c:IsMonster() and c:IsRace(RACE_ZOMBIE) and c:IsLevelBelow(4) and (c:IsAbleToHand() or c:IsAbleToGrave())
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.Group(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		Duel.HintSelection(Group.FromCards(e:GetHandler()))
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.HintMessage(tp,HINTMSG_OPERATECARD)
			local tc=g:Select(tp,1,1,nil):GetFirst()
			if tc then
				local b1=tc:IsAbleToHand()
				local b2=tc:IsAbleToGrave()
				local opt=aux.Option(tp,false,false,{b1,STRING_ADD_TO_HAND},{b2,STRING_SEND_TO_GY})
				Duel.Hint(HINT_CARD,0,id)
				if opt==0 then
					Duel.Search(tc,tp)
				elseif opt==1 then
					Duel.SendtoGrave(tc,REASON_EFFECT)
				end
			end
		end
	end
end
function s.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp,re)
		and re and re:IsHasType(EFFECT_TYPE_ACTIONS) and not re:IsHasType(EFFECT_TYPE_CONTINUOUS)
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	Duel.RegisterFlagEffect(tp,id,RESET_CHAIN,0,1)
end
function s.condition_afterchain(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)>0
end
function s.operation_afterchain(e,tp,eg,ep,ev,re,r,rp)
	local n=Duel.GetFlagEffect(tp,id)
	Duel.ResetFlagEffect(tp,id)
	local g=Duel.Group(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 then
		Duel.HintSelection(Group.FromCards(e:GetHandler()))
		if Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.HintMessage(tp,HINTMSG_OPERATECARD)
			if n==1 then
				local tc=g:Select(tp,1,1,nil):GetFirst()
				if tc then
					local b1=tc:IsAbleToHand()
					local b2=tc:IsAbleToGrave()
					local opt=aux.Option(tp,false,false,{b1,STRING_ADD_TO_HAND},{b2,STRING_SEND_TO_GY})
					Duel.Hint(HINT_CARD,0,id)
					if opt==0 then
						Duel.Search(tc,tp)
					elseif opt==1 then
						Duel.SendtoGrave(tc,REASON_EFFECT)
					end
				end
				
			else
				local temp,g1,g2=Group.CreateGroup(),Group.CreateGroup(),Group.CreateGroup()
				while #g1+#g2<n do
					local cg=Duel.Group(s.thfilter,tp,LOCATION_DECK,0,temp)
					if #cg==0 then break end
					local finish=#temp>0
					local tc=cg:SelectUnselect(temp,tp,finish,false,1,n)
					if not tc then break end
					if not temp:IsContains(tc) then
						temp:AddCard(tc)
						local b1=tc:IsAbleToHand()
						local b2=tc:IsAbleToGrave()
						local opt=aux.Option(tp,false,false,{b1,STRING_ADD_TO_HAND},{b2,STRING_SEND_TO_GY})
						if opt==0 then
							g1:AddCard(tc)
						elseif opt==1 then
							g2:AddCard(tc)
						end
					else
						temp:RemoveCard(tc)
						if g1:IsContains(tc) then
							g1:RemoveCard(tc)
						else
							g2:RemoveCard(tc)
						end
					end
				end
				if #g1>0 then
					Duel.Search(g1,tp)
				end
				if #g2>0 then
					Duel.SendtoGrave(g2,REASON_EFFECT)
				end
			end
		end
	end
end

--E4
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return aux.PhylacteryCheck(tp) and aux.exccon(e,tp,eg,ep,ev,re,r,rp)
end
function s.thfilter2(c)
	return c:IsFaceup() and (c:IsRace(RACE_ZOMBIE) or (c:IsSetCard(ARCHE_LICH_LORD) and c:IsST())) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.thfilter2(chkc) end
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToDeck() and Duel.IsExistingTarget(s.thfilter2,tp,LOCATION_REMOVED,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter2,tp,LOCATION_REMOVED,0,1,1,nil)
	Duel.SetCardOperationInfo(c,CATEGORY_TODECK)
	Duel.SetCardOperationInfo(g,CATEGORY_TOHAND)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.ShuffleIntoDeck(c)>0 then
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() and s.thfilter2(tc) then
			Duel.Search(tc,tp)
		end
	end
end

--E5
function s.descon(e)
	local tp=e:GetHandlerPlayer()
	return Duel.IsEndPhase(tp) and not aux.PhylacteryCheck(tp)
end