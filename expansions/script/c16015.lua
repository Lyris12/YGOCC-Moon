--Paracyclisavior of Life, Relishing Shield

local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	aux.AddFusionProcFunRep(c,s.matfilter,2,true)
	--spsummon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.hspcon)
	e1:SetCost(aux.ConfirmRuleCost)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	e1:SetCountLimit(1,id)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:Desc(1)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.atktg)
	e2:SetOperation(s.atkop)
	e2:SetCountLimit(1,id+100)
	c:RegisterEffect(e2)
end
s.material_setcode=0x308

function s.matfilter(c)
	return c:IsFusionSetCard(0x308) and c:GetLevel()<=5
end

function s.hspcon(e,tp,eg,ep,ev,re,r,rp)
	local b=Duel.GetAttackTarget()
	return b and b:IsFaceup() and b:IsControler(tp) and b:IsLocation(LOCATION_MZONE) and b:IsSetCard(0x308) and not b:IsType(TYPE_FUSION|TYPE_LINK)
end
function s.filter(c)
	return c:IsRace(RACE_INSECT) and c:IsAbleToDeck()
end
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local a=Duel.GetAttacker()
	if chk==0 then
		return s.sprcon(e,c) and (a:IsCanTurnSetGlitchy(tp) or a:IsAbleToGrave())
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,LOCATION_EXTRA)
	if a and a:IsRelateToBattle() then
		local cat
		if a:IsCanTurnSetGlitchy(tp) then
			cat=CATEGORY_POSITION
		else
			cat=CATEGORY_TOGRAVE
		end
		Duel.SetOperationInfo(0,cat,a,1,a:GetControler(),a:GetLocation())
	end
end
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCondition(s.sprcon)
	e1:SetTarget(s.sprtg)
	e1:SetOperation(s.sprop)
	e1:SetValue(s.sprval)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	Duel.SpecialSummonRule(tp,c,SUMMON_TYPE_FUSION+1)
end
function s.sprfilter1(c,sc)
	return c:IsFusionType(TYPE_MONSTER) and c:IsRace(RACE_INSECT) and c:IsAbleToDeckAsCost() and c:IsCanBeFusionMaterial(sc)
end
function s.sprfilter2(c,sc)
	return c:IsDiscardable(REASON_COST|REASON_MATERIAL|REASON_FUSION) and c:IsCanBeFusionMaterial(sc)
end
function s.sprcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local g1=Duel.GetMatchingGroup(s.sprfilter1,tp,LOCATION_GRAVE,0,nil,c)
	local g2=Duel.GetMatchingGroup(s.sprfilter2,tp,LOCATION_HAND,0,nil,c)
	return #g1>=2 and #g2>=1 and Duel.GetLocationCountFromEx(tp,tp,nil,c,EXTRA_MONSTER_ZONE)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false,POS_FACEUP,tp,EXTRA_MONSTER_ZONE)
end
function s.sprtg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g1=Duel.GetMatchingGroup(s.sprfilter1,tp,LOCATION_GRAVE,0,nil,c)
	local g2=Duel.GetMatchingGroup(s.sprfilter2,tp,LOCATION_HAND,0,nil,c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local sg1=g1:Select(tp,2,2,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	local sg2=g2:Select(tp,1,1,sg1)
	sg1:Merge(sg2)
	if #sg1>0 then
		sg1:KeepAlive()
		e:SetLabelObject(sg1)
		return true
	else
		return false
	end
end
function s.sprop(e,tp,eg,ep,ev,re,r,rp,c)
	local sg=e:GetLabelObject()
	local gg=sg:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
	local hg=sg:Filter(Card.IsLocation,nil,LOCATION_HAND)
	if #gg>0 then
		Duel.HintSelection(gg)
		Duel.SendtoDeck(gg,tp,SEQ_DECKSHUFFLE,REASON_COST|REASON_MATERIAL|REASON_FUSION)
	end
	if #hg>0 then
		Duel.SendtoGrave(hg,REASON_COST|REASON_DISCARD|REASON_MATERIAL|REASON_FUSION)
	end
	c:SetMaterial(sg)
	sg:DeleteGroup()
	
	local e1=Effect.CreateEffect(e:GetOwner())
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SET_AVAILABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.continueop)
	c:RegisterEffect(e1)
end
function s.sprval(e,c)
	return SUMMON_TYPE_FUSION+1,EXTRA_MONSTER_ZONE
end

function s.continueop(e,tp,eg,ep,ev,re,r,rp)	
	local tc=Duel.GetAttacker()
	if tc:IsRelateToBattle() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		Duel.BreakEffect()
		if Duel.NegateAttack() then
			if tc:IsCanTurnSetGlitchy(tp) then
				if Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)~=0 then
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
			else
				Duel.SendtoGrave(tc,REASON_EFFECT)
			end
		end
	end
	e:Reset()
end
function s.limcon(e)
	local ct,tp=e:GetLabel()
	return Duel.GetTurnCount()>ct and Duel.GetTurnPlayer()==1-tp
end

function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION) and Duel.IsExistingMatchingCard(Card.IsPosition,tp,0,LOCATION_MZONE,2,nil,POS_FACEDOWN_DEFENSE)
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
function s.thfilter(c)
	return c:IsRace(RACE_INSECT) and c:GetLevel()<=5 and c:IsAbleToHand()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		Duel.Search(g,tp)
	end
end
