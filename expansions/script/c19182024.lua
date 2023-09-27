--Aircaster Xenogenesis
--created by Alastar Rainford, originally coded by Lyris
--Rescripted by XGlitchy30

local s,id=GetID()
function s.initial_effect(c)
	aux.AddRitualProcEqual2(c,s.ritual_filter)
	local e1=Effect.CreateEffect(c)
	e1:Desc(0)
	e1:SetCategory(CATEGORY_REMOVE|CATEGORY_TOGRAVE|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsRace(RACE_PSYCHIC)
end

function s.check(tp)
	return	function(i)
				return Duel.IsPlayerCanDiscardDeck(tp,i)
			end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
	if chk==0 then return ct>0 and c:IsAbleToRemove() and Duel.IsPlayerCanDiscardDeck(tp,ct) and Duel.IsPlayerCanSendtoGrave(tp) end
	Duel.SetCardOperationInfo(c,CATEGORY_REMOVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,ct,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if c:IsRelateToChain() and Duel.Banish(c)>0 then
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		if ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) then
		
			local eff=Effect.CreateEffect(c)
			eff:Desc(1)
			eff:SetCategory(CATEGORY_REMOVE)
			eff:SetType(EFFECT_TYPE_FIELD|EFFECT_TYPE_TRIGGER_F)
			eff:SetCode(EVENT_TO_GRAVE)
			eff:SetFunctions(s.rmcon,nil,s.rmtg,s.rmop)
			eff:SetReset(RESET_PHASE|PHASE_END)
			eff:SetLabel(e:GetFieldID())
			eff:SetLabelObject(e)
			Duel.RegisterEffect(eff,tp)
			
			local n=Duel.AnnounceNumberMinMax(tp,ct,ct*2,s.check(tp))
			Duel.BreakEffect()
			Duel.ConfirmDecktop(tp,n)
			local g=Duel.GetDecktopGroup(tp,n)
			local sg=g:Filter(aux.AircasterExcavateFilter,nil)
			if #sg>0 then
				Duel.DisableShuffleCheck()
				Duel.SendtoGrave(sg,REASON_EFFECT|REASON_EXCAVATE)
			end
			Duel.ShuffleDeck(tp)
		end
	end
end

function s.cfilter(c,eid,e)
	local re=c:GetReasonEffect()
	return c:IsMonster() and c:IsRace(RACE_PSYCHIC) and c:IsReason(REASON_EFFECT) and re and re==e and re:GetFieldID()==eid
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	if not re then return false end
	local eid=e:GetLabel()
	if not eid then return false end
	return eg:IsExists(s.cfilter,1,nil,eid,e:GetLabelObject())
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local eid=e:GetLabel()
	local ct=eg:FilterCount(s.cfilter,nil,eid,e:GetLabelObject())
	Duel.SetTargetParam(ct)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,ct,1-tp,LOCATION_GRAVE)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetTargetParam()
	local g=Duel.GetFieldGroup(tp,0,LOCATION_GRAVE)
	if #g<ct then return end
	local sg=g:FilterSelect(tp,Card.IsAbleToRemove,ct,ct,nil)
	if #sg>0 then
		Duel.DisableShuffleCheck()
		Duel.Banish(sg)
	end
end