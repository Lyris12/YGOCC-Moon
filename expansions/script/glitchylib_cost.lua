--COSTS
-----------------------------------------------------------------------
function Auxiliary.InfoCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
function Auxiliary.LabelCost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end

function Auxiliary.DiscardCost(f,min,max)
	if not f then f=Card.IsDiscardable end
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return Duel.IsExistingMatchingCard(f,tp,LOCATION_HAND,0,min,nil) end
				Duel.DiscardHand(tp,f,min,max,REASON_COST+REASON_DISCARD)
			end
end
function Auxiliary.BanishCost(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(aux.BanishFilter(f,true),tp,loc1,loc2,min,exc,e,tp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
				local g=Duel.SelectMatchingCard(tp,aux.BanishFilter(f,true),tp,loc1,loc2,min,max,exc,e,tp)
				if #g>0 then
					local ct=Duel.Remove(g,POS_FACEUP,REASON_COST)
					return g,ct
				end
				return g,0
			end
end
function Auxiliary.ToGraveCost(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(aux.ToGraveFilter(f,true),tp,loc1,loc2,min,exc,e,tp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local g=Duel.SelectMatchingCard(tp,aux.ToGraveFilter(f,true),tp,loc1,loc2,min,max,exc,e,tp)
				if #g>0 then
					local ct=Duel.SendtoGrave(g,REASON_COST)
					return g,ct
				end
				return g,0
			end
end
function Auxiliary.ToDeckCost(f,loc1,loc2,min,max,exc)
	if not loc1 then loc1=LOCATION_ONFIELD end
	if not loc2 then loc2=loc1 end
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local exc=(not exc) and nil or e:GetHandler()
				if chk==0 then return Duel.IsExistingMatchingCard(aux.ToDeckFilter(f,true),tp,loc1,loc2,min,exc,e,tp) end
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
				local g=Duel.SelectMatchingCard(tp,aux.ToDeckFilter(f,true),tp,loc1,loc2,min,max,exc,e,tp)
				if #g>0 then
					local ct=Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)
					return g,ct
				end
				return g,0
			end
end

-----------------------------------------------------------------------
--Self as Cost
function Auxiliary.DiscardSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
function Auxiliary.DetachSelfCost(min,max)
	if not min then min=1 end
	if not max then max=min end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,min,REASON_COST) end
				e:GetHandler():RemoveOverlayCard(tp,min,max,REASON_COST)
			end
end
function Auxiliary.ToExtraSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToExtraAsCost() end
	Duel.SendtoDeck(e:GetHandler(),nil,SEQ_DECKSHUFFLE,REASON_COST)
end
function Auxiliary.ToGraveSelfCost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end

-----------------------------------------------------------------------
--Restrictions (Limits)
function Card.SSCounter(c,f)
	return Duel.AddCustomActivityCounter(c:GetOriginalCode(),ACTIVITY_SPSUMMON,f)
end
function Auxiliary.SSLimit(f,desc,oath,reset)
	local oath=oath and EFFECT_FLAG_OATH or 0
	if not reset then reset=RESET_PHASE+PHASE_END end
	return	function(e,tp,eg,ep,ev,re,r,rp,chk)
				local id=e:GetHandler():GetOriginalCode()
				if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:Desc(desc)
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+oath+EFFECT_FLAG_CLIENT_HINT)
				e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
				e1:SetReset(reset)
				e1:SetTargetRange(1,0)
				e1:SetTarget(	function(eff,c,sump,sumtype,sumpos,targetp,se)
									return not f(c,eff,sump,sumtype,sumpos,targetp,se)
								end
							)
				Duel.RegisterEffect(e1,tp)
			end
end

function Card.ActivationCounter(c,f)
	return Duel.AddCustomActivityCounter(c:GetOriginalCode(),ACTIVITY_CHAIN,f)
end