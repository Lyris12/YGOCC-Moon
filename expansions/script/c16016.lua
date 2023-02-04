--Paracyclissavior Legion, Infinite Sting

local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	aux.AddContactFusionProcedureGlitchy(c,0,false,SUMMON_TYPE_FUSION,Card.IsAbleToGraveAsCost,LOCATION_MZONE,0,Duel.SendtoGrave,REASON_COST|REASON_FUSION|REASON_MATERIAL)
	--tohand
	local e1=Effect.CreateEffect(c)
	e1:Desc(1)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DDD)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	--
	local e2=Effect.CreateEffect(c)
	e2:Desc(2)
	e2:SetCategory(CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	e2:SetCountLimit(1,id+100)
	c:RegisterEffect(e2)
end
s.material_setcode=0x308

function s.matfilter(c)
	return c:IsFusionSetCard(0x308) and c:IsLevelBelow(5)
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function s.cfilter(c)
	return c:IsSetCard(0x308) and c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.thfilter(c,tp)
	return c:IsAbleToHand(1-tp) and Duel.GetMZoneCount(1-tp,c)>0
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_MZONE,nil,tp)
	if chk==0 then return #g>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_DECK)>0 and Duel.IsPlayerCanSpecialSummon(1-tp) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,1-tp,LOCATION_MZONE)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEDOWN_DEFENSE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter,tp,0,LOCATION_MZONE,nil,tp)
	if #g<=0 then return end
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_RTOHAND)
	local sg=g:Select(1-tp,1,1,nil)
	if #sg>0 then
		Duel.HintSelection(sg)
		if Duel.SendtoHand(sg,nil,REASON_EFFECT)>=0 and sg:IsExists(aux.PLChk,1,nil,1-tp,LOCATION_HAND) then
			Duel.ShuffleHand(1-tp)
			if Duel.IsExistingMatchingCard(s.spfilter,tp,0,LOCATION_DECK,1,nil,e,tp) then
				Duel.BreakEffect()
				Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)
				local spg=Duel.SelectMatchingCard(1-tp,s.spfilter,tp,0,LOCATION_DECK,1,1,nil,e,tp)
				if #spg>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.SpecialSummonStep(spg:GetFirst(),0,1-tp,1-tp,false,false,POS_FACEDOWN_DEFENSE) then
					local e1=Effect.CreateEffect(e:GetHandler())
					e1:Desc(3)
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
					spg:GetFirst():RegisterEffect(e1)
				end
				Duel.SpecialSummonComplete()
			end
		end
	end
end
function s.limcon(e)
	local ct,tp=e:GetLabel()
	return Duel.GetTurnCount()>ct and Duel.GetTurnPlayer()==1-tp
end

function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler()==Duel.GetAttacker()
		and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsDefensePos()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local d=Duel.GetAttackTarget()
	if d and d:IsControler(1-tp) then
		Duel.SetCustomOperationInfo(0,CATEGORY_DEFCHANGE,d,1,1-tp,LOCATION_MZONE,{math.ceil(d:GetDefense()/2)})
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsRelateToBattle() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE+RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetTarget(s.halftg)
	e2:SetValue(s.halfval)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	Duel.RegisterEffect(e2,tp)
end
function s.halftg(e,c)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	return a==e:GetOwner() and d and d==c
end
function s.halfval(e,c)
	return math.ceil(c:GetDefense()/2)
end