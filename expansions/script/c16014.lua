--Paracyclisity Meteor Impact, Stagdominator

local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,s.matfilter,2,99,s.lcheck)
	local e3=Effect.CreateEffect(c)
	e3:Desc(0)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_POSITION+CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCondition(aux.LinkSummonedCond)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	e3:SetCountLimit(1,id)
	c:RegisterEffect(e3)
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	e1:SetCountLimit(1,id+100)
	c:RegisterEffect(e1)
end
function s.matfilter(c)
	return c:IsLinkSetCard(0x308) and c:IsLinkType(TYPE_LINK)
end
function s.lcheck(g,lg)
	return g:GetClassCount(Card.GetCode)==#g
end

function s.spfun(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP,1-tp)
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g1=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,nil,tp)
	local g2=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToGrave),tp,0,LOCATION_MZONE,nil)
	if #g1>0 then
		Duel.SetOperationInfo(0,CATEGORY_POSITION,g1,#g1,1-tp,LOCATION_MZONE)
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,#g1*500)
	end
	if #g2>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g2,#g2,1-tp,LOCATION_MZONE)
	end
end
function s.desop(e,tp)
	local g=Duel.GetMatchingGroup(Card.IsType,tp,0,LOCATION_DECK,nil,TYPE_MONSTER)
	if #g>=5 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tg=g:Select(1-tp,5,5,nil)
		if #tg>0 then
			Duel.ConfirmCards(tp,tg)
			local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
			if ft>0 then
				if Duel.IsPlayerAffectedByEffect(1-tp,CARD_BLUEEYES_SPIRIT) then
					ft=1
				end
				local sg1=tg:Filter(s.spfun,nil,e,tp)
				if #sg1>ft then
					Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
					sg1=sg1:Select(1-tp,ft,ft,nil)
				end
				if Duel.SpecialSummon(sg1,0,1-tp,1-tp,false,false,POS_FACEUP)>0 then
					local g1=Duel.GetMatchingGroup(Card.IsCanTurnSetGlitchy,tp,0,LOCATION_MZONE,nil,tp)
					if #g1>0 then
						Duel.BreakEffect()
						if Duel.ChangePosition(g1,POS_FACEDOWN_DEFENSE)>0 then
							local ct=Duel.GetOperatedGroup():FilterCount(Card.IsPosition,nil,POS_FACEDOWN_DEFENSE)
							if Duel.Damage(1-tp,ct*500,REASON_EFFECT)>0 then
								local g2=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAbleToGrave),tp,0,LOCATION_MZONE,nil)
								if #g2>0 then
									Duel.BreakEffect()
									Duel.SendtoGrave(g2,REASON_EFFECT)
								end
							end
						end
					end
				end
			end
		end
	end
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
	for tc in aux.Next(g) do
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:Desc(2)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCondition(s.limcon)
		if Duel.GetTurnPlayer()==tp then
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
		else
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
		end
		e1:SetLabel(Duel.GetTurnCount(),tp)
		tc:RegisterEffect(e1)
	end
end
function s.limcon(e)
	local ct,tp=e:GetLabel()
	return Duel.GetTurnCount()>ct and Duel.GetTurnPlayer()==1-tp
end

function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.CheckLPCost(tp,2000)
	local b=Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,2,nil)
	if chk==0 then return a or b end
	if a and b then
		local opt=Duel.SelectOption(tp,aux.Stringid(id,3),aux.Stringid(id,4))
		if opt==0 then
			Duel.PayLPCost(tp,2000)
		elseif opt==1 then
			Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
		end
	elseif a then
		Duel.PayLPCost(tp,2000)
	elseif b then
		Duel.DiscardHand(tp,Card.IsDiscardable,2,2,REASON_COST+REASON_DISCARD)
	end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
	if chk==0 then return ct>0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=Duel.GetMatchingGroupCount(Card.IsPosition,tp,0,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
	Duel.Damage(p,ct*500,REASON_EFFECT)
end
