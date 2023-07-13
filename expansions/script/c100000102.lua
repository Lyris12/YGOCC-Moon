--Aeonstrider Oracle
--Oracolo Marciaeoni
--Scripted by: XGlitchy30

local s,id,o=GetID()
xpcall(function() require("expansions/script/glitchylib_helper") end,function() require("script/glitchylib_helper") end)
xpcall(function() require("expansions/script/glitchylib_aeonstride") end,function() require("script/glitchylib_aeonstride") end)
function s.initial_effect(c)
	aux.EnablePendulumAttribute(c,false)
	aux.SpawnGlitchyHelper(GLITCHY_HELPER_TURN_COUNT_FLAG)
	aux.RaiseAeonstrideEndOfTurnEvent(c)
	c:Activation()
	--[[This card's Pendulum Scale is equal to the current Turn Count.]]
	local p0=Effect.CreateEffect(c)
	p0:SetType(EFFECT_TYPE_SINGLE)
	p0:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE|EFFECT_FLAG_UNCOPYABLE|EFFECT_FLAG_CANNOT_DISABLE|EFFECT_FLAG_SINGLE_RANGE)
	p0:SetCode(EFFECT_CHANGE_LSCALE)
	p0:SetRange(LOCATION_PZONE)
	p0:SetValue(s.scale)
	c:RegisterEffect(p0)
	local p00=p0:Clone()
	p00:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(p00)
	--[[During your Main Phase: You can excavate cards from the top of your Deck, equal to the current Turn Count +2,
	and if you do, you can either add to your hand, or banish, 1 excavated "Aeonstride" card, then move the Turn Count forwards by 1 turn, also shuffle the rest into the Deck.]]
	local p1=Effect.CreateEffect(c)
	p1:Desc(0)
	p1:SetCategory(CATEGORIES_SEARCH|CATEGORY_REMOVE)
	p1:SetType(EFFECT_TYPE_IGNITION)
	p1:SetRange(LOCATION_PZONE)
	p1:HOPT()
	p1:SetFunctions(nil,nil,s.exctg,s.excop)
	c:RegisterEffect(p1)
	--[[If this card is added to the Extra Deck, face-up: You can move the Turn Count forwards by 1 turn, then you can destroy 1 Spell/Trap your opponent controls.]]
	local e1=Effect.CreateEffect(c)
	e1:Desc(2)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE|EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_DECK)
	e1:HOPT()
	e1:SetFunctions(s.descon,nil,s.destg,s.desop)
	c:RegisterEffect(e1)
	--[[If the Turn Count moves forwards, while this card is face-up in your Extra Deck, or banished (except during the Damage Step):
	You can place this card in your Pendulum Zone, or, if you control an "Aeonstride" monster, you can Special Summon it. ]]
	local EDChk=aux.AddThisCardInExtraAlreadyCheck(c,POS_FACEUP,Effect.SetLabelObjectObject,Effect.GetLabelObjectObject)
	local RMChk=aux.AddThisCardBanishedAlreadyCheck(c)
	EDChk:SetLabelObject(RMChk)
	local e2=Effect.CreateEffect(c)
	e2:Desc(4)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TURN_COUNT_MOVED)
	e2:SetRange(LOCATION_EXTRA|LOCATION_REMOVED)
	e2:HOPT()
	e2:SetLabelObject(RMChk)
	e2:SetFunctions(s.spcon,nil,s.sptg,s.spop)
	c:RegisterEffect(e2)
	aux.RegisterTurnCountTriggerEffectFlag(c,e2)
end
--P0
function s.scale(e,c)
	return Duel.GetTurnCount(nil,true)
end

--F1
function s.excfilter(c)
	return c:IsSetCard(ARCHE_AEONSTRIDE) and (c:IsAbleToHand() or c:IsAbleToRemove())
end
--P1
function s.exctg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ct=Duel.GetTurnCount(nil,true)+2
		return Duel.GetDeckCount(tp)>=ct and (Duel.IsPlayerCanSendtoHand(tp) or Duel.IsPlayerCanRemove(tp))
			and Duel.GetDecktopGroup(tp,ct):IsExists(aux.OR(Card.IsAbleToHand,Card.IsAbleToRemove),1,nil)
			and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT)
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
function s.excop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTurnCount(nil,true)+2
	if ct<=0 or Duel.GetDeckCount(tp)<ct then return end
	local c=e:GetHandler()
	Duel.ConfirmDecktop(tp,ct)
	local g=Duel.GetDecktopGroup(tp,ct):Filter(s.excfilter,nil)
	if #g>0 and c:AskPlayer(tp,1) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			local tc=sg:GetFirst()
			local check=false
			local opt=aux.Option(tp,false,false,{tc:IsAbleToHand(),STRING_ADD_TO_HAND},{tc:IsAbleToRemove(),STRING_BANISH})
			if opt==0 then
				if Duel.SendtoHand(tc,nil,REASON_EFFECT|REASON_EFFECT|REASON_EXCAVATE)>0 and aux.PLChk(tc,tp,LOCATION_HAND) then
					Duel.ConfirmCards(1-tp,Group.FromCards(tc))
					check=true
				end
			elseif opt==1 then
				if Duel.Banish(tc,nil,REASON_EFFECT|REASON_EXCAVATE)>0 then
					check=true
				end
			end
			if check and Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) then
				Duel.BreakEffect()
				Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)
			end
		end
	end
	Duel.ShuffleDeck(tp)
end

--E1
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsInExtra(POS_FACEUP)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanMoveTurnCount(1,e,tp,REASON_EFFECT) end
	local g=Duel.Group(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,g,1,1-tp,LOCATION_ONFIELD)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.MoveTurnCountCustom(1,e,tp,REASON_EFFECT)~=0 then
		local g=Duel.Group(Card.IsSpellTrapOnField,tp,0,LOCATION_ONFIELD,nil)
		if #g>0 and e:GetHandler():AskPlayer(tp,3) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,1,nil)
			if #sg>0 then
				Duel.HintSelection(sg)
				Duel.BreakEffect()
				Duel.Destroy(sg,REASON_EFFECT)
			end
		end
	end
end

--E2
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return se==nil or not re or re~=se
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		return (Duel.CheckPendulumZones(tp) and c:CheckUniqueOnField(tp) and not c:IsForbidden())
			or (Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_AEONSTRIDE),tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetMZoneCountFromLocation(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
	end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,c:GetControler(),c:GetLocation())
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToChain() then
		local b1=(Duel.CheckPendulumZones(tp) and c:CheckUniqueOnField(tp) and not c:IsForbidden())
		local b2=(Duel.IsExists(false,aux.FaceupFilter(Card.IsSetCard,ARCHE_AEONSTRIDE),tp,LOCATION_MZONE,0,1,nil)
			and Duel.GetMZoneCountFromLocation(tp,tp,nil,c)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false))
			
		local opt=aux.Option(tp,false,false,{b1,STRING_PLACE_IN_PZONE},{b2,STRING_SPECIAL_SUMMON})
		if opt==0 then
			Duel.MoveToField(c,tp,tp,LOCATION_PZONE,POS_FACEUP,true)
		elseif opt==1 then
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end