--Agricolteschio Tagliardore
--Scripted by: XGlitchy30

local s,id=GetID()

s.effect_text = [[
● You can only Special Summon "Agriskullture Burncutter" once per turn with the ① effect.
● You can only use the ② and ③ effect of "Agriskulture Burncutter" once per turn.

① You can Special Summon this card (from your hand) to your Main Monster Zone that was previously occupied by a monster you controlled, and that was banished from that zone or sent from that zone to the GY this turn.
② When this card is Special Summoned: You can target 1 monster in your GY, or that is among your banished cards, that was sent to the GY, or banished, from the Main Monster Zone this card was Special Summoned into; shuffle it into the Deck, and if you do, add from your Deck to your hand, 1 monster with the same Type and Attribute as that monster, but a lower Level.
③ While this card is in your GY, except the turn this card was sent to the GY, if you have no banished "Agriskullture Burncutter": You can banish this card from your GY; the next time you Special Summon "Agriskullture Burncutter", shuffle all your banished "Agriskullture Burncutter" into the Deck, and if you shuffled at least 1, you can destroy 1 monster your opponent controls.
]]

function s.initial_effect(c)
	c:SSProc(0,nil,nil,{1,0},s.zcon,nil,nil,nil,nil,s.zone)
	local e2=c:SummonedTrigger(false,false,true,false,1,CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND,EFFECT_FLAG_CARD_TARGET,{1,1},nil,nil,s.target,s.operation)
	c:Ignition(2,nil,nil,LOCATION_GRAVE,{1,2},s.ncond,aux.bfgcost,aux.Check(),s.nextop)
	--
	if not s.global_check then
		s.global_check=true
		local g1=Effect.CreateEffect(c)
		g1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		g1:SetCode(EVENT_REMOVE)
		g1:SetOperation(s.regop)
		Duel.RegisterEffect(g1,0)
		local g2=g1:Clone()
		g2:SetCode(EVENT_TO_GRAVE)
		Duel.RegisterEffect(g2,0)
	end
end
function s.regf(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:GetPreviousSequence()<5 and (c:GetPreviousTypeOnField()&TYPE_MONSTER==TYPE_MONSTER or c:IsPreviousPosition(POS_FACEDOWN))
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(s.regf,nil)
	if #g<=0 then return end
	for tc in aux.Next(g) do
		local p=tc:GetPreviousControler()
		local z = (p==tp) and 1<<tc:GetPreviousSequence() or 1<<(4-tc:GetPreviousSequence())
		if not tc:HasFlagEffect(id) then
			tc:RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
		end
		if tc:GetFlagEffectLabel(id)&z==0 then
			tc:UpdateFlagEffectLabel(id,z)
		end
		if Duel.GetFlagEffect(p,id)<=0 then
			Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1)
		end
		if Duel.GetFlagEffectLabel(p,id)&z==0 then
			Duel.UpdateFlagEffectLabel(p,id,z)
		end
	end
end
function s.zcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zones=Duel.GetFlagEffectLabel(tp,id)
	return Duel.GetFlagEffect(tp,id)>0 and zones~=0 and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zones&0x1f)>0
end
function s.zone(e,c)
	local zones=Duel.GetFlagEffectLabel(c:GetControler(),id)
	if not zones then zones=0 end
	return 0,zones&0x1f
end

function s.filter(c,e,tp)
	local zone=e:GetLabel()
	return c:IsMonster() and c:HasFlagEffect(id) and c:GetFlagEffectLabel(id)&zone~=0 and c:HasLevel() and c:IsAbleToDeck()
		and Duel.IsExists(false,s.thf,tp,LOCATION_DECK,0,1,c,c:GetRace(),c:GetAttribute(),c:GetLevel())
end
function s.thf(c,race,attr,lv)
	return c:IsMonster() and c:IsRace(race) and c:IsAttribute(attr) and c:HasLevel() and c:GetLevel()<lv and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local prechk =	function(e)
						local c=e:GetHandler()
						if not c:IsLocation(LOCATION_MZONE) or c:GetSequence()>5 then return false end
						e:SetLabel(1<<c:GetSequence())
					end
	local info =	function(g,_,tp)
						Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,0,0)
						Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
					end
	return aux.Target(s.filter,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,false,info,prechk,true)(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local race,attr,lv=tc:GetRace(),tc:GetAttribute(),tc:GetLevel()
		if Duel.ShuffleIntoDeck(tc)>0 then
			local g=Duel.Select(HINTMSG_ATOHAND,false,tp,s.thf,tp,LOCATION_DECK,0,1,1,nil,race,attr,lv)
			if #g>0 then
				Duel.Search(g,tp)
			end
		end
	end
end

function s.cf(c)
	return c:IsFaceup() and c:IsCode(id)
end
function s.ncond(e,tp)
	return aux.ExactLocationGroupCond(s.cf,LOCATION_REMOVED,0,0)(e,tp) and aux.exccon(e)
end
function s.nextop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Effect.CreateEffect(e:GetHandler())
	g1:Desc(4)
	g1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	g1:SetCode(EVENT_SPSUMMON_SUCCESS)
	g1:SetOperation(s.tdop)
	Duel.RegisterEffect(g1,0)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,tp,id)
	local g=Duel.Group(aux.ToDeckFilter(s.cf),tp,LOCATION_REMOVED,0,nil)
	if #g>0 and Duel.ShuffleIntoDeck(g)>0 and Duel.IsExists(false,aux.TRUE,tp,0,LOCATION_MZONE,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		local dg=Duel.Select(HINTMSG_DESTROY,false,tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
		if #dg>0 then
			Duel.HintSelection(dg)
			Duel.Destroy(dg,REASON_EFFECT)
		end
	end
	e:Reset()
end