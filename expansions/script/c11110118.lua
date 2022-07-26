--Condottrice del Cielodorato Nata dalla Dianaceleste, Erith Katelin
--Scripted by: XGlitchy30

local s,id = GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x223,0x528),aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),true)
	--send to GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(aux.FusionSummonedCond)
	e1:SetCost(s.cost)
	e1:SetTarget(s.tgtg(s.filter1,LOCATION_HAND+LOCATION_DECK))
	e1:SetOperation(s.tgop(s.filter1,LOCATION_HAND+LOCATION_DECK))
	c:RegisterEffect(e1)
	--send to GY (triggers when banished)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCode(EVENT_REMOVE)
	e2:SetCountLimit(1,id+100)
	e2:SetCost(s.cost)
	e2:SetTarget(s.tgtg(s.filter2,LOCATION_DECK))
	e2:SetOperation(s.tgop(s.filter2,LOCATION_DECK))
	c:RegisterEffect(e2)
	--destroy
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+100)
	e3:SetCondition(function(e,tp) return Duel.IsMainPhase(tp) end)
	e3:SetCost(s.dtrcost)
	e3:SetTarget(s.dtrtg)
	e3:SetOperation(s.dtrop)
	c:RegisterEffect(e3)
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
function s.counterfilter(c)
	return c:IsRace(RACE_WARRIOR)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c)
	return not s.counterfilter(c)
end
function s.filter1(c)
	return c:IsCode(11111040) and c:IsAbleToGrave()
end
function s.filter2(c)
	return c:IsSetCard(0x223,0x528) and c:IsAbleToGrave()
end
function s.tgtg(f,loc)
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,loc,0,1,nil) end
				Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,loc)
			end
end
function s.tgop(f,loc)
	return	function(e,tp,eg,ep,ev,re,r,rp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local g=Duel.SelectMatchingCard(tp,f,tp,loc,0,1,1,nil)
				if #g>0 then
					Duel.SendtoGrave(g,REASON_EFFECT)
				end
			end
end

function s.cfilter(c,e,tp)
	return c:IsMonster() and c:IsSetCard(0x223) and c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(s.dtrfilter,tp,LOCATION_EXTRA,0,1,c,e)
end
function s.dtrfilter(c,e)
	return c:IsMonster() and c:IsDestructable(e)
end
function s.tdfilter(c)
	return c:IsCode(11111040) and c:IsAbleToDeckAsCost()
end
function s.dtrcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) and Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,1,nil) and s.cost(e,tp,eg,ep,ev,re,r,rp,0)
	end
	s.cost(e,tp,eg,ep,ev,re,r,rp,1)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g1=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g1>0 then
		Duel.Remove(g1,POS_FACEUP,REASON_COST)
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g2=Duel.SelectMatchingCard(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g2>0 then
		Duel.HintSelection(g2)
		Duel.SendtoDeck(g2,tp,SEQ_DECKSHUFFLE,REASON_COST)
	end
end
function s.infofilter(c,e)
	return c:IsFacedown() or c:IsMonster() and c:IsDestructable(e)
end
function s.dtrtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local res = e:GetLabel()==1 or Duel.IsExistingMatchingCard(s.dtrfilter,tp,LOCATION_EXTRA,0,1,nil,e)
		e:SetLabel(0)
		return res
	end
	e:SetLabel(0)
	local g=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0):Filter(s.infofilter,nil,e)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,tp,LOCATION_EXTRA)
end
function s.dtrop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.dtrfilter,tp,LOCATION_EXTRA,0,1,1,nil,e)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end