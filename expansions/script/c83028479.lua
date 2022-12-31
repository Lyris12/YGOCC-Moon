--Dinoscienziato
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
● You can only use each effect of "Dinoscientist" once per turn.
● You can only activate 1 Spell during the turn you activate this card's ① effect.

① When a Reptile or Dinosaur monster is Normal Summoned while this card is in your hand: You can destroy this card in your hand and up to 1 other monster in your hand and/or field, then Special Summon an equal number of "DiNA Token" (DARK/Level 2/Dinosaur/ATK 100/DEF 500).
② If this card is in your GY: You can Tribute any number of "DiNA Token"; Special Summon an equal number of Reptile and Dinosaur monsters from your GY, including this card, but banish them when they leave the field.

]]

function s.initial_effect(c)
	--Token
	local e0=c:SummonedFieldTrigger(nil,false,true,false,false,0,CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_TOKEN,nil,LOCATION_HAND,{1,0},
									aux.EventGroupCond(s.egf,1,nil,true),s.cost,aux.Check(s.check,aux.HandlerInfo(CATEGORY_DESTROY),
									aux.Info(CATEGORY_SPECIAL_SUMMON,1,0,0),aux.Info(CATEGORY_TOKEN,1,0,0)),s.operation)
	--SS
	local e1=c:Ignition(3,CATEGORY_SPECIAL_SUMMON,nil,LOCATION_GRAVE,{1,1},nil,aux.LabelCost,aux.CostCheck(s.spcheck,s.spcost,aux.HandlerInfo(CATEGORY_SPECIAL_SUMMON)),s.spop)
	--activate limit
	aux.GlobalCheck(s,function()
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e2:SetCode(EVENT_CHAINING)
		e2:SetOperation(s.aclimit1)
		Duel.RegisterEffect(e2,0)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e3:SetCode(EVENT_CHAIN_NEGATED)
		e3:SetOperation(s.aclimit2)
		Duel.RegisterEffect(e3,0)
	end)
end
function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL) then return end
	if Duel.GetFlagEffect(ep,id)<=0 then
		Duel.RegisterFlagEffect(ep,id,RESET_PHASE+PHASE_END,0,1,0)
	end
	Duel.UpdateFlagEffectLabel(ep,id)
end
function s.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) or not re:IsActiveType(TYPE_SPELL) or Duel.GetFlagEffect(ep,id)<=0 then return end
	Duel.UpdateFlagEffectLabel(ep,id,-1)
end
function s.econ(e,tp)
	if not tp then tp=e:GetHandlerPlayer() end
	return Duel.GetFlagEffect(tp,id)<=0 or Duel.GetFlagEffectLabel(tp,id)<=1
end
function s.econ2(e,tp)
	if not tp then tp=e:GetHandlerPlayer() end
	return Duel.GetFlagEffect(tp,id)>0 and Duel.GetFlagEffectLabel(tp,id)>=1
end

function s.egf(c)
	return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_REPTILE+RACE_DINOSAUR)
end
function s.filter(c,e,tp)
	return c:IsMonster() and (c:IsLocation(LOCATION_MZONE) or c:IsDestructable(e)) and Duel.GetMZoneCount(tp,c)>1
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return s.econ(e,tp) end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:Desc(2)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.econ2)
	e1:SetValue(s.elimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.elimit(e,te,tp)
	return te:IsHasType(EFFECT_TYPE_ACTIVATE) and te:IsActiveType(TYPE_SPELL)
end
function s.check(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDestructable(e)
	and (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 or Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,e:GetHandler(),e,tp)
	and not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT))
	and Duel.IsPlayerCanSpecialSummonMonster(tp,83028480,0,TYPES_TOKEN,100,500,2,RACE_DINOSAUR,ATTRIBUTE_DARK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c and c:IsRelateToEffect(e) and c:IsDestructable(e) then
		local g=Group.FromCards(c)
		if Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,e,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_MZONE,0,0,1,nil,e,tp)
			if #sg>0 then
				Duel.HintSelection(g)
				g:AddCard(sg:GetFirst())
			end
		end
		if #g>0 then
			local ct=Duel.Destroy(g,REASON_EFFECT)
			Debug.Message(ct)
			if ct>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>=ct and Duel.IsPlayerCanSpecialSummonMonster(tp,83028480,0,TYPES_TOKEN,100,500,2,RACE_DINOSAUR,ATTRIBUTE_DARK)
			and (ct==1 or not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)) then
				Duel.BreakEffect()
				for i=1,2 do
					local token=Duel.CreateToken(tp,83028480)
					Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP)
				end
				Duel.SpecialSummonComplete()
			end
		end
	end
end

function s.cfilter(c,tp)
	return c:IsCode(83028480) and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
function s.spfilter(c,e,tp)
	return c:IsMonster() and c:IsRace(RACE_REPTILE+RACE_DINOSAUR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcheck(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-1 and Duel.CheckReleaseGroupCost(tp,s.cfilter,1,false,nil,nil,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ct=Duel.GetMatchingGroupCount(s.spfilter,tp,LOCATION_GRAVE,0,e:GetHandler(),e,tp)
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ct=0 end
	local rg=Duel.SelectReleaseGroupCost(tp,s.cfilter,1,ct+1,false,nil,nil,tp)
	local spct=Duel.Release(rg,REASON_COST)
	Duel.SetTargetParam(spct)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c or not c:IsRelateToEffect(e) then return end
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local ct=Duel.GetTargetParam()
	if ft<ct then return end
	local g=Group.FromCards(c)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local dg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE,0,ct-1,ct-1,nil,e,tp)
	g:Merge(dg)
	if #g==ct then
		Duel.SpecialSummonRedirect(e,g,0,tp,tp,false,false,POS_FACEUP)
	end
end